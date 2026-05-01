import { mkdtemp, readdir, stat, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { spawn, type ChildProcess } from "node:child_process";
import { Type } from "typebox";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const VisualCheckParams = Type.Object({
	backend: Type.Optional(Type.String({ description: "Screenshot backend: auto, wayland, or x11. Default: auto, preferring hidden Wayland when available in Wayland sessions." })),
	command: Type.String({
		description:
			"Command to run inside the hidden terminal, for example: nvim -u nvim/.config/nvim/init.lua +'edit foo.lua'",
	}),
	cwd: Type.Optional(Type.String({ description: "Working directory for the command. Defaults to Pi's current cwd." })),
	output: Type.Optional(Type.String({ description: "PNG output path. Defaults to a temp file." })),
	width: Type.Optional(Type.Number({ description: "Virtual display width in pixels. Default: 1200." })),
	height: Type.Optional(Type.Number({ description: "Virtual display height in pixels. Default: 800." })),
	delayMs: Type.Optional(Type.Number({ description: "Milliseconds to wait before taking the screenshot. Default: 1500." })),
	terminal: Type.Optional(Type.String({ description: "Terminal command. Defaults to foot for Wayland backend and xterm for X11 backend." })),
	fontSize: Type.Optional(Type.Number({ description: "Terminal font size when using xterm. Default: 12." })),
});

type ExecResult = {
	code: number | null;
	stdout: string;
	stderr: string;
};

function sleep(ms: number, signal?: AbortSignal) {
	return new Promise<void>((resolvePromise, reject) => {
		if (signal?.aborted) {
			reject(new Error("visual_check cancelled"));
			return;
		}

		const timeout = setTimeout(resolvePromise, ms);
		const abort = () => {
			clearTimeout(timeout);
			reject(new Error("visual_check cancelled"));
		};
		signal?.addEventListener("abort", abort, { once: true });
	});
}

function killProcess(proc: ChildProcess | undefined) {
	if (!proc || proc.killed) return;
	try {
		proc.kill("SIGTERM");
	} catch {
		// ignore cleanup errors
	}
}

function execFile(command: string, args: string[], options: { cwd?: string; env?: NodeJS.ProcessEnv; signal?: AbortSignal } = {}) {
	return new Promise<ExecResult>((resolvePromise, reject) => {
		const proc = spawn(command, args, {
			cwd: options.cwd,
			env: options.env,
			stdio: ["ignore", "pipe", "pipe"],
		});

		let stdout = "";
		let stderr = "";
		proc.stdout?.on("data", (chunk) => {
			stdout += chunk.toString();
		});
		proc.stderr?.on("data", (chunk) => {
			stderr += chunk.toString();
		});
		proc.on("error", reject);
		proc.on("close", (code) => resolvePromise({ code, stdout, stderr }));

		const abort = () => {
			killProcess(proc);
			reject(new Error(`${command} cancelled`));
		};
		options.signal?.addEventListener("abort", abort, { once: true });
	});
}

async function commandExists(command: string) {
	const result = await execFile("sh", ["-lc", `command -v ${JSON.stringify(command)} >/dev/null 2>&1`]);
	return result.code === 0;
}


async function listWaylandSockets(runtimeDir: string) {
	try {
		const names = await readdir(runtimeDir);
		return new Set(names.filter((name) => /^wayland-\d+$/.test(name)));
	} catch {
		return new Set<string>();
	}
}

async function findNewWaylandSocket(runtimeDir: string, before: Set<string>, timeoutMs: number, signal?: AbortSignal) {
	const deadline = Date.now() + timeoutMs;
	while (Date.now() < deadline) {
		const current = await listWaylandSockets(runtimeDir);
		for (const name of current) {
			if (!before.has(name)) return name;
		}
		await sleep(100, signal);
	}
	throw new Error("Timed out waiting for hidden Wayland compositor socket");
}

async function runWaylandCapture(params: {
	command: string;
	cwd: string;
	output: string;
	width: number;
	height: number;
	delayMs: number;
	terminal: string;
	signal?: AbortSignal;
}) {
	const runtimeDir = process.env.XDG_RUNTIME_DIR || `/run/user/${process.getuid?.() ?? ""}`;
	const beforeSockets = await listWaylandSockets(runtimeDir);
	const tempDir = await mkdtemp(join(tmpdir(), "pi-visual-check-wayland-"));
	const script = join(tempDir, "run.sh");
	const swayConfig = join(tempDir, "sway.conf");
	await writeFile(script, `#!/bin/sh\ncd ${JSON.stringify(params.cwd)} || exit 1\n${params.command}\n`, { mode: 0o700 });
	await writeFile(
		swayConfig,
		[
			`output * resolution ${params.width}x${params.height}`,
			"default_border none",
			"default_floating_border none",
			`exec ${params.terminal} sh ${script}`,
			"",
		].join("\n"),
		"utf8",
	);

	let sway: ChildProcess | undefined;
	try {
		sway = spawn("sway", ["-c", swayConfig], {
			env: {
				...process.env,
				XDG_RUNTIME_DIR: runtimeDir,
				WLR_BACKENDS: "headless",
				WLR_LIBINPUT_NO_DEVICES: "1",
			},
			stdio: ["ignore", "ignore", "pipe"],
		});
		let swayStderr = "";
		sway.stderr?.on("data", (chunk) => {
			swayStderr += chunk.toString();
		});

		const waylandDisplay = await findNewWaylandSocket(runtimeDir, beforeSockets, 3000, params.signal);
		await sleep(params.delayMs, params.signal);
		if (sway.exitCode !== null) {
			throw new Error(`Hidden sway exited before screenshot: ${swayStderr.trim()}`);
		}

		const capture = await execFile("grim", [params.output], {
			env: { ...process.env, XDG_RUNTIME_DIR: runtimeDir, WAYLAND_DISPLAY: waylandDisplay },
			signal: params.signal,
		});
		if (capture.code !== 0) {
			throw new Error(`Wayland screenshot capture failed: ${capture.stderr || capture.stdout}`);
		}
		await waitForFile(params.output, 2000, params.signal);
		return { display: waylandDisplay };
	} finally {
		killProcess(sway);
	}
}

async function waitForFile(path: string, timeoutMs: number, signal?: AbortSignal) {
	const deadline = Date.now() + timeoutMs;
	while (Date.now() < deadline) {
		try {
			const info = await stat(path);
			if (info.size > 0) return;
		} catch {
			// keep waiting
		}
		await sleep(100, signal);
	}
	throw new Error(`Screenshot was not created: ${path}`);
}

function makeDisplayNumber() {
	return 90 + Math.floor(Math.random() * 900);
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "visual_check",
		label: "Visual Check",
		description:
			"Run a UI command inside a hidden virtual display, capture a PNG screenshot, and return its path. Prefers a hidden Wayland/wlroots backend in Wayland sessions, then falls back to Xvfb/X11. Use this for autonomous verification of Neovim/UI visual changes before claiming they look correct.",
		promptSnippet: "Capture hidden screenshots for autonomous visual verification of UI changes.",
		promptGuidelines: [
			"Use visual_check after making Neovim tabline, statusline, colorscheme, highlight, icon, or other visual UI changes, then inspect the returned PNG path with the read tool before claiming the visual result is correct.",
			"Do not treat headless Neovim highlight assertions as sufficient visual verification when visual_check can run.",
		],
		parameters: VisualCheckParams,

		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const width = Math.max(320, Math.floor(params.width ?? 1200));
			const height = Math.max(240, Math.floor(params.height ?? 800));
			const delayMs = Math.max(0, Math.floor(params.delayMs ?? 1500));
			const fontSize = Math.max(6, Math.floor(params.fontSize ?? 12));
			const cwd = resolve(ctx.cwd, params.cwd ?? ".");
			const tempDir = await mkdtemp(join(tmpdir(), "pi-visual-check-"));
			const output = params.output ? resolve(ctx.cwd, params.output) : join(tempDir, "screenshot.png");
			const requestedBackend = (params.backend ?? "auto").toLowerCase();
			if (!["auto", "wayland", "x11"].includes(requestedBackend)) {
				throw new Error(`Invalid visual_check backend '${params.backend}'. Use auto, wayland, or x11.`);
			}

			const inWaylandSession = process.env.XDG_SESSION_TYPE === "wayland" || !!process.env.WAYLAND_DISPLAY;
			const waylandTerminal = params.terminal ?? "foot";
			const x11Terminal = params.terminal ?? "xterm";
			const canWayland =
				(await commandExists("sway")) && (await commandExists("grim")) && (await commandExists(waylandTerminal));
			const useWayland =
				requestedBackend === "wayland" || (requestedBackend === "auto" && inWaylandSession && canWayland);

			if (useWayland) {
				const missing: string[] = [];
				for (const command of ["sway", "grim", waylandTerminal]) {
					if (!(await commandExists(command))) missing.push(command);
				}
				if (missing.length > 0) {
					throw new Error(
						`visual_check wayland backend is unavailable. Missing: ${missing.join(", ")}. Install sway, grim, and ${waylandTerminal}.`,
					);
				}

				const result = await runWaylandCapture({
					command: params.command,
					cwd,
					output,
					width,
					height,
					delayMs,
					terminal: waylandTerminal,
					signal,
				});

				return {
					content: [
						{
							type: "text" as const,
							text: `Hidden Wayland visual screenshot captured: ${output}\nRead this PNG with the read tool and inspect it before making any visual correctness claim.`,
						},
					],
					details: {
						backend: "wayland",
						output,
						width,
						height,
						display: result.display,
						terminal: waylandTerminal,
						command: params.command,
						cwd,
					},
				};
			}

			const missing: string[] = [];
			for (const command of ["Xvfb", x11Terminal, "import"]) {
				if (!(await commandExists(command))) missing.push(command);
			}
			if (missing.length > 0) {
				throw new Error(
					`visual_check x11 backend is unavailable. Missing: ${missing.join(", ")}. Install Xvfb plus an X11 terminal and ImageMagick, e.g. on Arch: sudo pacman -S xorg-server-xvfb xterm imagemagick`,
				);
			}

			const display = `:${makeDisplayNumber()}`;
			const env = { ...process.env, DISPLAY: display };
			let xvfb: ChildProcess | undefined;
			let term: ChildProcess | undefined;

			try {
				xvfb = spawn("Xvfb", [display, "-screen", "0", `${width}x${height}x24`, "-nolisten", "tcp"], {
					stdio: ["ignore", "ignore", "pipe"],
				});
				let xvfbStderr = "";
				xvfb.stderr?.on("data", (chunk) => {
					xvfbStderr += chunk.toString();
				});

				await sleep(400, signal);
				if (xvfb.exitCode !== null) {
					throw new Error(`Xvfb exited early: ${xvfbStderr.trim()}`);
				}

				const cols = Math.max(40, Math.floor(width / Math.max(7, fontSize * 0.62)));
				const rows = Math.max(10, Math.floor(height / Math.max(12, fontSize * 1.85)));
				const terminalArgs = x11Terminal.endsWith("xterm")
					? [
							"-T",
							"pi-visual-check",
							"-geometry",
							`${cols}x${rows}+0+0`,
							"-fa",
							"monospace",
							"-fs",
							String(fontSize),
							"-e",
							"sh",
							"-lc",
							params.command,
						]
					: ["-e", "sh", "-lc", params.command];

				term = spawn(x11Terminal, terminalArgs, {
					cwd,
					env,
					stdio: ["ignore", "ignore", "pipe"],
				});
				let termStderr = "";
				term.stderr?.on("data", (chunk) => {
					termStderr += chunk.toString();
				});

				await sleep(delayMs, signal);
				if (term.exitCode !== null) {
					throw new Error(`Terminal exited before screenshot. stderr: ${termStderr.trim()}`);
				}

				const capture = await execFile("import", ["-window", "root", output], { env, signal });
				if (capture.code !== 0) {
					throw new Error(`Screenshot capture failed: ${capture.stderr || capture.stdout}`);
				}
				await waitForFile(output, 2000, signal);

				return {
					content: [
						{
							type: "text" as const,
							text: `Hidden X11 visual screenshot captured: ${output}\nRead this PNG with the read tool and inspect it before making any visual correctness claim.`,
						},
					],
					details: {
						backend: "x11",
						output,
						width,
						height,
						display,
						terminal: x11Terminal,
						command: params.command,
						cwd,
					},
				};
			} finally {
				killProcess(term);
				killProcess(xvfb);
			}
		},
	});
}
