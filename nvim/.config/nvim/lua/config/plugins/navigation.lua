local M = {}

local lazy = require("config.plugins.lazy")

local function configure_fyler()
	require("fyler").setup({
		integrations = {
			icon = "nvim_web_devicons",
		},
		views = {
			finder = {
				default_explorer = true,
				close_on_select = false,
				mappings = {
					["-"] = "GotoParent",
				},
				win = {
					kind = "replace",
					win_opts = {
						signcolumn = "yes",
						number = true,
						relativenumber = true,
						cursorline = true,
					},
				},
				columns_order = { "link", "git", "diagnostic" },
				columns = {
					git = { enabled = true },
					diagnostics = { enabled = true },
					link = { enabled = true },
					permissions = { enabled = false },
					size = { enabled = false },
				},
			},
		},
	})

	pcall(vim.api.nvim_del_augroup_by_name, "UserFylerDirectoryAutoload")
end

local function open_directory_buffer_with_fyler(bufnr)
	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(bufnr) or vim.api.nvim_get_current_buf() ~= bufnr then
			return
		end

		local dirname = vim.api.nvim_buf_get_name(bufnr)
		if dirname == "" or vim.fn.isdirectory(dirname) ~= 1 or vim.bo[bufnr].filetype == "fyler" then
			return
		end

		lazy.run("fyler.nvim", configure_fyler, function()
			if vim.api.nvim_buf_is_valid(bufnr) then
				vim.api.nvim_buf_delete(bufnr, { force = true })
			end
			require("fyler").open({ dir = dirname })
		end)
	end)
end

local function setup_fyler_directory_autoload()
	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("UserFylerDirectoryAutoload", { clear = true }),
		callback = function(args)
			open_directory_buffer_with_fyler(args.buf)
		end,
	})

	vim.api.nvim_create_autocmd("VimEnter", {
		group = vim.api.nvim_create_augroup("UserFylerStartupDirectory", { clear = true }),
		once = true,
		callback = function()
			open_directory_buffer_with_fyler(vim.api.nvim_get_current_buf())
		end,
	})
end

local function setup_fyler()
	setup_fyler_directory_autoload()

	lazy.map("n", "<leader>e", "fyler.nvim", configure_fyler, function()
		require("fyler").toggle({ kind = "split_left_most" })
	end, { desc = "Toggle file tree" })

	lazy.map("n", "-", "fyler.nvim", configure_fyler, function()
		require("fyler").open({ kind = "float" })
	end, { desc = "Open file explorer" })

	vim.api.nvim_create_user_command("Ex", function()
		lazy.run("fyler.nvim", configure_fyler, function()
			require("fyler").open({ kind = "replace" })
		end)
	end, { desc = "Open fyler float", force = true })
end

local function configure_fzf_lua()
	local function get_git_root(bufnr)
		local root = vim.fs.root(bufnr or 0, { ".git" })
		if root and root ~= "" then
			return root
		end
		return vim.uv.cwd()
	end

	local git_root = get_git_root()
	local fzf_opts = {
		fzf_colors = true,
		files = {
			cwd = git_root,
			cwd_prompt = false,
			fd_opts = "--type f --hidden --follow --exclude .git",
		},
		grep = {
			cwd = git_root,
			rg_opts = "--hidden --smart-case --column --line-number --no-heading --color=never --glob '!.git/*'",
		},
		live_grep = {
			cwd = git_root,
			rg_opts = "--hidden --smart-case --column --line-number --no-heading --color=never --glob '!.git/*'",
		},
	}

	if vim.fn.executable("sk") ~= 1 then
		error("skim (sk) is not installed or not on PATH")
	end

	fzf_opts.fzf_bin = "sk"
	fzf_opts.fzf_opts = {
		["--algo"] = "arinae",
		["--typos"] = true,
	}

	require("fzf-lua").setup(fzf_opts)
	require("fzf-lua").register_ui_select()
end

local function configure_fzf_frecency()
	lazy.setup_once("fzf-lua", configure_fzf_lua)
	require("fzf-lua-frecency").setup()
end

local function setup_fzf_lsp_keymaps()
	local lsp_group = vim.api.nvim_create_augroup("FzfLspConfig", { clear = true })
	local inlay_group = vim.api.nvim_create_augroup("FzfLspInlayHints", { clear = false })

	local function fzf_lsp(method, opts)
		return function()
			lazy.run("fzf-lua", configure_fzf_lua, function()
				require("fzf-lua")[method](opts)
			end)
		end
	end

	local function set_lsp_keymaps(bufnr)
		local opts = { buffer = bufnr, silent = true }

		vim.keymap.set(
			"n",
			"grr",
			fzf_lsp("lsp_references", { ignore_current_line = true, multi = true }),
			vim.tbl_extend("force", opts, { desc = "Fzf References" })
		)
		vim.keymap.set(
			"n",
			"gd",
			fzf_lsp("lsp_definitions", {
				jump1 = true,
				cwd_only = false,
				silent = false,
			}),
			vim.tbl_extend("force", opts, { desc = "Fzf Definitions" })
		)
		vim.keymap.set(
			"n",
			"gD",
			fzf_lsp("lsp_declarations", { jump1 = true }),
			vim.tbl_extend("force", opts, { desc = "Fzf Declarations" })
		)
		vim.keymap.set(
			"n",
			"gI",
			fzf_lsp("lsp_implementations", { jump1 = true }),
			vim.tbl_extend("force", opts, { desc = "Fzf Implementations" })
		)
		vim.keymap.set(
			"n",
			"gy",
			fzf_lsp("lsp_typedefs", { jump1 = true }),
			vim.tbl_extend("force", opts, { desc = "Fzf Type Definitions" })
		)
		vim.keymap.set(
			{ "n", "v" },
			"<leader>ca",
			fzf_lsp("lsp_code_actions", { multi = true }),
			vim.tbl_extend("force", opts, { desc = "Fzf Code Actions" })
		)
		vim.keymap.set(
			{ "n", "v" },
			"gra",
			fzf_lsp("lsp_code_actions", { multi = true }),
			vim.tbl_extend("force", opts, { desc = "Fzf Code Actions" })
		)
		vim.keymap.set(
			"n",
			"<leader>cd",
			fzf_lsp("diagnostics_document"),
			vim.tbl_extend("force", opts, { desc = "Fzf Document Diagnostics" })
		)
		vim.keymap.set(
			"n",
			"<leader>cD",
			fzf_lsp("diagnostics_workspace"),
			vim.tbl_extend("force", opts, { desc = "Fzf Workspace Diagnostics" })
		)
		vim.keymap.set(
			"n",
			"<leader>ce",
			fzf_lsp("diagnostics_document", {
				severity_only = vim.diagnostic.severity.ERROR,
			}),
			vim.tbl_extend("force", opts, { desc = "Fzf Document Errors" })
		)
		vim.keymap.set(
			"n",
			"<leader>cs",
			fzf_lsp("lsp_document_symbols"),
			vim.tbl_extend("force", opts, { desc = "Fzf Document Symbols" })
		)
		vim.keymap.set(
			"n",
			"<leader>cS",
			fzf_lsp("lsp_workspace_symbols"),
			vim.tbl_extend("force", opts, { desc = "Fzf Workspace Symbols" })
		)

		vim.api.nvim_clear_autocmds({ group = inlay_group, buffer = bufnr })
		vim.api.nvim_create_autocmd("InsertEnter", {
			group = inlay_group,
			buffer = bufnr,
			callback = function()
				local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
				vim.b[bufnr].inlay_hints_was_enabled = is_enabled
				if is_enabled then
					vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
				end
			end,
		})
		vim.api.nvim_create_autocmd("InsertLeave", {
			group = inlay_group,
			buffer = bufnr,
			callback = function()
				if vim.b[bufnr].inlay_hints_was_enabled then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end
			end,
		})
	end

	vim.api.nvim_create_autocmd("LspAttach", {
		group = lsp_group,
		callback = function(ev)
			set_lsp_keymaps(ev.buf)
		end,
	})

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) and #vim.lsp.get_clients({ bufnr = bufnr }) > 0 then
			set_lsp_keymaps(bufnr)
		end
	end
end

local function install_fzf_lua_command()
	vim.api.nvim_create_user_command("FzfLua", function(opts)
		lazy.run("fzf-lua", configure_fzf_lua, function()
			local unpack_args = unpack or table.unpack
			require("fzf-lua.cmd").run_command(unpack_args(opts.fargs))
		end)
	end, {
		nargs = "*",
		range = true,
		force = true,
		complete = function(_, line)
			lazy.setup_once("fzf-lua", configure_fzf_lua)
			return require("fzf-lua.cmd")._candidates(line)
		end,
	})
end

local function setup_fzf_lua()
	install_fzf_lua_command()
	vim.api.nvim_create_autocmd("VimEnter", {
		group = vim.api.nvim_create_augroup("UserFzfLuaCommand", { clear = true }),
		once = true,
		callback = install_fzf_lua_command,
	})

	local function fzf(method, opts)
		return function()
			lazy.run("fzf-lua", configure_fzf_lua, function()
				require("fzf-lua")[method](opts)
			end)
		end
	end

	vim.keymap.set("n", "<leader>f", fzf("files", { multi = true }), { desc = "Find Files" })
	vim.keymap.set("n", "<leader>F", fzf("git_files", { multi = true }), { desc = "Find Git Files" })
	lazy.map("n", "<leader>fr", "fzf-lua-frecency.nvim", configure_fzf_frecency, function()
		require("fzf-lua-frecency").frecency({ cwd_only = true })
	end, { desc = "Find Frecent Files" })
	vim.keymap.set("n", "<leader>gg", fzf("live_grep", { multi = true }), { desc = "Live Grep" })
	vim.keymap.set("n", "<leader>gG", fzf("grep", { multi = true }), { desc = "Grep" })
	vim.keymap.set("n", "<leader>gf", fzf("grep_project", { multi = true }), { desc = "Fuzzy Grep" })
	vim.keymap.set("n", "<leader>gw", fzf("grep_cword", { multi = true }), { desc = "Grep Word Under Cursor" })
	vim.keymap.set("n", "<leader>b", fzf("buffers", { multi = true }), { desc = "Find Buffers" })
	vim.keymap.set("n", "<leader>t", fzf("btags", { multi = true }), { desc = "Buffer Tags" })
	vim.keymap.set("n", "<leader><tab>", fzf("keymaps"), { desc = "Search Keymaps" })
	vim.keymap.set("i", "<c-x><c-f>", fzf("complete_path"), { desc = "Complete Path" })
	vim.keymap.set("i", "<c-x><c-l>", fzf("complete_line"), { desc = "Complete Line" })
	vim.keymap.set("i", "<c-x><c-j>", fzf("complete_file"), { desc = "Complete File" })

	setup_fzf_lsp_keymaps()
end

local function configure_grug_far()
	require("grug-far").setup({})
end

local function configure_todo_comments()
	require("todo-comments").setup({
		signs = false,
		highlight = {
			before = "",
			keyword = "wide_fg",
			after = "empty",
		},
	})
end

local function setup_navigation_extras()
	lazy.map({ "n", "x" }, "<leader>sr", "grug-far.nvim", configure_grug_far, function()
		require("grug-far").open()
	end, { desc = "Search and Replace" })

	lazy.map("n", "]t", "todo-comments.nvim", configure_todo_comments, function()
		require("todo-comments").jump_next()
	end, { desc = "Next todo comment" })
	lazy.map("n", "[t", "todo-comments.nvim", configure_todo_comments, function()
		require("todo-comments").jump_prev()
	end, { desc = "Previous todo comment" })

	local function configure_trouble()
		require("trouble").setup({})
	end
	local function trouble_command(args)
		return function()
			vim.cmd("Trouble " .. args)
		end
	end

	lazy.command("Trouble", "trouble.nvim", configure_trouble, function(opts)
		vim.cmd("Trouble " .. opts.args)
	end, { nargs = "*", desc = "Trouble" })
	lazy.map(
		"n",
		"<leader>xt",
		"trouble.nvim",
		configure_trouble,
		trouble_command("todo toggle"),
		{ desc = "Todos (Trouble)" }
	)
	lazy.map(
		"n",
		"<leader>xx",
		"trouble.nvim",
		configure_trouble,
		trouble_command("diagnostics toggle"),
		{ desc = "Diagnostics (Trouble)" }
	)
	lazy.map(
		"n",
		"<leader>xX",
		"trouble.nvim",
		configure_trouble,
		trouble_command("diagnostics toggle filter.buf=0"),
		{ desc = "Buffer Diagnostics (Trouble)" }
	)
	lazy.map(
		"n",
		"<leader>xl",
		"trouble.nvim",
		configure_trouble,
		trouble_command("loclist toggle"),
		{ desc = "Location List (Trouble)" }
	)
	lazy.map(
		"n",
		"<leader>xq",
		"trouble.nvim",
		configure_trouble,
		trouble_command("qflist toggle"),
		{ desc = "Quickfix List (Trouble)" }
	)

	local function configure_flash()
		require("flash").setup({})
	end
	lazy.map({ "n", "x", "o" }, "s", "flash.nvim", configure_flash, function()
		require("flash").jump()
	end, { desc = "Flash" })
	lazy.map({ "n", "x", "o" }, "S", "flash.nvim", configure_flash, function()
		require("flash").treesitter()
	end, { desc = "Flash Treesitter" })
	lazy.map("o", "r", "flash.nvim", configure_flash, function()
		require("flash").remote()
	end, { desc = "Remote Flash" })
	lazy.map({ "o", "x" }, "R", "flash.nvim", configure_flash, function()
		require("flash").treesitter_search()
	end, { desc = "Treesitter Search" })
	lazy.map("c", "<C-s>", "flash.nvim", configure_flash, function()
		require("flash").toggle()
	end, { desc = "Toggle Flash Search" })
end

local function setup_tmux_navigator()
	local directions = {
		Left = "h",
		Down = "j",
		Up = "k",
		Right = "l",
		Previous = "\\",
	}

	for direction, key in pairs(directions) do
		local command = "TmuxNavigate" .. direction
		lazy.command(command, "vim-tmux-navigator", nil, function()
			vim.cmd(command)
		end, { desc = command })
		lazy.map("n", "<C-a>" .. key, "vim-tmux-navigator", nil, function()
			vim.cmd(command)
		end)
	end
end

function M.setup()
	setup_fyler()
	setup_fzf_lua()
	setup_navigation_extras()
	setup_tmux_navigator()
end

return M
