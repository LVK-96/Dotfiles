import os
import subprocess
import tempfile
from pathlib import Path
import tomllib
import unittest


REPO_ROOT = Path(__file__).resolve().parents[1]
GREETD_CONFIG_PATH = REPO_ROOT / "greetd" / ".config" / "greetd" / "config.toml"
INSTALLER_PATH = REPO_ROOT / "utils" / "install-greetd-cage-gtkgreet.sh"
README_PATH = REPO_ROOT / "greetd" / "README.md"
EXPECTED_GREETER_COMMAND = "cage -s -- gtkgreet -c sway"


class GreetdCageGtkgreetTests(unittest.TestCase):
    def test_greetd_default_session_uses_cage_gtkgreet(self):
        self.assertTrue(
            GREETD_CONFIG_PATH.is_file(),
            f"missing planned greetd config: {GREETD_CONFIG_PATH}",
        )

        config = tomllib.loads(GREETD_CONFIG_PATH.read_text())

        self.assertEqual(config.get("terminal", {}).get("vt"), 2)
        self.assertEqual(
            config.get("default_session", {}).get("command"), EXPECTED_GREETER_COMMAND
        )
        self.assertEqual(config.get("default_session", {}).get("user"), "greeter")

    def test_installer_installs_config_and_enables_greetd(self):
        self.assertTrue(
            INSTALLER_PATH.is_file(),
            f"missing planned installer: {INSTALLER_PATH}",
        )

        with tempfile.TemporaryDirectory() as tmpdir:
            tmp_path = Path(tmpdir)
            bin_dir = tmp_path / "bin"
            bin_dir.mkdir()
            log_path = tmp_path / "calls.log"

            for name, body in {
                "sudo": "#!/bin/sh\nexec \"$@\"\n",
                "install": (
                    "#!/bin/sh\n"
                    "printf '%s\n' \"install $*\" >> \"$LOG_FILE\"\n"
                    "exit 0\n"
                ),
                "systemctl": (
                    "#!/bin/sh\n"
                    "printf '%s\n' \"systemctl $*\" >> \"$LOG_FILE\"\n"
                    "exit 0\n"
                ),
            }.items():
                path = bin_dir / name
                path.write_text(body)
                path.chmod(0o755)

            env = os.environ.copy()
            env["PATH"] = f"{bin_dir}:{env['PATH']}"
            env["LOG_FILE"] = str(log_path)

            subprocess.run(
                [str(INSTALLER_PATH)],
                cwd=REPO_ROOT,
                env=env,
                check=True,
            )

            self.assertEqual(
                log_path.read_text().splitlines(),
                [
                    f"install -Dm644 {GREETD_CONFIG_PATH} /etc/greetd/config.toml",
                    "systemctl enable --now greetd.service",
                ],
            )

    def test_readme_describes_install_and_rollback(self):
        self.assertTrue(
            README_PATH.is_file(),
            f"missing planned README: {README_PATH}",
        )

        readme = README_PATH.read_text()

        self.assertIn("./utils/install-greetd-cage-gtkgreet.sh", readme)
        self.assertIn("systemctl enable --now greetd.service", readme)
        self.assertIn("systemctl disable --now ly@tty2.service", readme)
        self.assertIn("systemctl disable --now ly-console-selector.service", readme)


if __name__ == "__main__":
    unittest.main()
