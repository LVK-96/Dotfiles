local M = {}

local regular_nvim = not vim.g.vscode

local function notify_error(message)
	vim.schedule(function()
		vim.notify(message, vim.log.levels.ERROR)
	end)
end

local function safe(name, callback)
	local ok, err = pcall(callback)
	if not ok then
		notify_error(string.format("Plugin config failed for %s: %s", name, err))
	end
end

local function setup_statusline()
	safe("mini.statusline", function()
		local statusline = require("mini.statusline")
		statusline.setup({
			content = {
				active = function()
					local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
					local git = statusline.section_git({ trunc_width = 40 })
					local diff = statusline.section_diff({ trunc_width = 75 })
					local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
					local filename = statusline.section_filename({ trunc_width = 140 })
					local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
					local search = statusline.section_searchcount({ trunc_width = 75 })
					local location = statusline.section_location({ trunc_width = 75 })

					local left = statusline.combine_groups({
						{ hl = mode_hl, strings = { mode } },
						{ hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics } },
						"%<",
						{ hl = "MiniStatuslineFilename", strings = { filename } },
					})

					local right = statusline.combine_groups({
						{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
						{ hl = mode_hl, strings = { search, location } },
					})

					return left .. "%=" .. right
				end,
			},
		})
	end)
end

local function setup_theme()
	if not regular_nvim then
		return
	end

	safe("nvim-solarized-lua", function()
		vim.o.background = "light"
		vim.cmd.colorscheme("solarized")
	end)
end

local function setup_oil()
	if not regular_nvim then
		return
	end

	vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open Parent Directory" })

	safe("oil.nvim", function()
		require("oil").setup({
			win_options = {
				signcolumn = "yes",
				number = true,
				relativenumber = true,
				cursorline = true,
			},
			view_options = {
				show_hidden = true,
				natural_order = true,
				is_always_hidden = function(name)
					return name == ".." or name == ".git"
				end,
			},
			cleanup_delay_ms = 2000,
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-s>"] = "actions.select_vsplit",
				["<C-h>"] = "actions.select_split",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
			},
			skip_confirm_for_simple_edits = true,
		})

		vim.api.nvim_create_autocmd("User", {
			pattern = "OilActionsPost",
			callback = function(args)
				if args.data.err then
					return
				end
				for _, action in ipairs(args.data.actions) do
					if action.type == "delete" then
						local _, path = require("oil.util").parse_url(action.url)
						local buf = vim.fn.bufnr(path)
						if buf ~= -1 and vim.api.nvim_buf_is_valid(buf) then
							vim.api.nvim_buf_delete(buf, { force = true })
						end
					end
				end
			end,
		})

		vim.api.nvim_create_user_command("Ex", "Oil", {})
	end)

	safe("oil-git-status.nvim", function()
		require("oil-git-status").setup()
	end)
end

local function setup_nvim_tree()
	vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })

	safe("nvim-tree.lua", function()
		require("nvim-tree").setup({
			view = {
				side = "left",
				width = 35,
				preserve_window_proportions = true,
			},
			git = { enable = true },
			diagnostics = { enable = true },
			filesystem_watchers = { enable = true },
			update_focused_file = {
				enable = true,
				update_root = false,
			},
			filters = {
				dotfiles = false,
			},
		})
	end)
end

local function setup_fzf_lua()
	vim.keymap.set("n", "<leader>f", function()
		require("fzf-lua").files({ multi = true })
	end, { desc = "Find Files" })
	vim.keymap.set("n", "<leader>F", function()
		require("fzf-lua").git_files({ multi = true })
	end, { desc = "Find Git Files" })
	vim.keymap.set("n", "<leader>gg", function()
		require("fzf-lua").live_grep({ multi = true })
	end, { desc = "Live Grep" })
	vim.keymap.set("n", "<leader>gG", function()
		require("fzf-lua").grep({ multi = true })
	end, { desc = "Grep" })
	vim.keymap.set("n", "<leader>gf", function()
		require("fzf-lua").grep_project({ multi = true })
	end, { desc = "Fuzzy Grep" })
	vim.keymap.set("n", "<leader>gw", function()
		require("fzf-lua").grep_cword({ multi = true })
	end, { desc = "Grep Word Under Cursor" })
	vim.keymap.set("n", "<leader>b", function()
		require("fzf-lua").buffers({ multi = true })
	end, { desc = "Find Buffers" })
	vim.keymap.set("n", "<leader>t", function()
		require("fzf-lua").btags({ multi = true })
	end, { desc = "Buffer Tags" })
	vim.keymap.set("n", "<leader><tab>", "<cmd>FzfLua keymaps<cr>", { desc = "Search Keymaps" })
	vim.keymap.set("i", "<c-x><c-f>", function()
		require("fzf-lua").complete_path()
	end, { desc = "Complete Path" })
	vim.keymap.set("i", "<c-x><c-l>", function()
		require("fzf-lua").complete_line()
	end, { desc = "Complete Line" })
	vim.keymap.set("i", "<c-x><c-j>", function()
		require("fzf-lua").complete_file()
	end, { desc = "Complete File" })

	safe("fzf-lua", function()
		local function get_git_root(bufnr)
			local root = vim.fs.root(bufnr or 0, { ".git" })
			if root and root ~= "" then
				return root
			end
			return vim.loop.cwd()
		end

		local git_root = get_git_root()
		require("fzf-lua").setup({
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
		})
		require("fzf-lua").register_ui_select()

		local lsp_group = vim.api.nvim_create_augroup("FzfLspConfig", { clear = true })
		local inlay_group = vim.api.nvim_create_augroup("FzfLspInlayHints", { clear = false })

		local function set_lsp_keymaps(bufnr)
			local opts = { buffer = bufnr, silent = true }

			vim.keymap.set("n", "grr", function()
				require("fzf-lua").lsp_references({ ignore_current_line = true, multi = true })
			end, vim.tbl_extend("force", opts, { desc = "Fzf References" }))

			vim.keymap.set("n", "gd", function()
				require("fzf-lua").lsp_definitions({
					jump1 = true,
					cwd_only = false,
					silent = false,
				})
			end, vim.tbl_extend("force", opts, { desc = "Fzf Definitions" }))

			vim.keymap.set("n", "gD", function()
				require("fzf-lua").lsp_declarations({ jump1 = true })
			end, vim.tbl_extend("force", opts, { desc = "Fzf Declarations" }))

			vim.keymap.set("n", "gI", function()
				require("fzf-lua").lsp_implementations({ jump1 = true })
			end, vim.tbl_extend("force", opts, { desc = "Fzf Implementations" }))

			vim.keymap.set("n", "gy", function()
				require("fzf-lua").lsp_typedefs({ jump1 = true })
			end, vim.tbl_extend("force", opts, { desc = "Fzf Type Definitions" }))

			vim.keymap.set({ "n", "v" }, "<leader>ca", function()
				require("fzf-lua").lsp_code_actions({ multi = true })
			end, vim.tbl_extend("force", opts, { desc = "Fzf Code Actions" }))

			vim.keymap.set({ "n", "v" }, "gra", function()
				require("fzf-lua").lsp_code_actions({ multi = true })
			end, vim.tbl_extend("force", opts, { desc = "Fzf Code Actions" }))

			vim.keymap.set("n", "<leader>cd", function()
				require("fzf-lua").diagnostics_document()
			end, vim.tbl_extend("force", opts, { desc = "Fzf Document Diagnostics" }))

			vim.keymap.set("n", "<leader>cD", function()
				require("fzf-lua").diagnostics_workspace()
			end, vim.tbl_extend("force", opts, { desc = "Fzf Workspace Diagnostics" }))

			vim.keymap.set("n", "<leader>ce", function()
				require("fzf-lua").diagnostics_document({
					severity_only = vim.diagnostic.severity.ERROR,
				})
			end, vim.tbl_extend("force", opts, { desc = "Fzf Document Errors" }))

			vim.keymap.set("n", "<leader>cs", function()
				require("fzf-lua").lsp_document_symbols()
			end, vim.tbl_extend("force", opts, { desc = "Fzf Document Symbols" }))

			vim.keymap.set("n", "<leader>cS", function()
				require("fzf-lua").lsp_workspace_symbols()
			end, vim.tbl_extend("force", opts, { desc = "Fzf Workspace Symbols" }))

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
	end)
end

local function setup_tmux_navigator()
	if not regular_nvim then
		return
	end

	vim.keymap.set("n", "<C-a>h", "<cmd>TmuxNavigateLeft<cr>")
	vim.keymap.set("n", "<C-a>j", "<cmd>TmuxNavigateDown<cr>")
	vim.keymap.set("n", "<C-a>k", "<cmd>TmuxNavigateUp<cr>")
	vim.keymap.set("n", "<C-a>l", "<cmd>TmuxNavigateRight<cr>")
	vim.keymap.set("n", "<C-a>\\", "<cmd>TmuxNavigatePrevious<cr>")
end

local function setup_gitsigns()
	if not regular_nvim then
		return
	end

	safe("gitsigns.nvim", function()
		require("gitsigns").setup({
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			numhl = true,
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns
				local function map(mode, lhs, rhs, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, lhs, rhs, opts)
				end

				map("n", "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true })
				map("n", "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true })
				map("n", "<leader>hp", gs.preview_hunk)
			end,
		})
	end)
end

local function setup_fugitive()
	if not regular_nvim then
		return
	end

	vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git Status" })
	vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git Blame" })
	vim.keymap.set("n", "<leader>glg", "<cmd>Git log --oneline --decorate --graph<CR>", { desc = "Git Log (Simple)" })
end

local function setup_treesitter()
	if not regular_nvim then
		return
	end

	safe("nvim-treesitter", function()
		local status_ok = pcall(require, "nvim-treesitter.configs")
		if not status_ok then
			return
		end

		require("nvim-treesitter.configs").setup({
			sync_install = false,
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = {
				enable = true,
			},
			matchup = {
				enable = true,
			},
			ensure_installed = {
				"bash",
				"c",
				"cpp",
				"css",
				"html",
				"javascript",
				"json",
				"lua",
				"markdown",
				"python",
				"rust",
				"toml",
				"typescript",
				"yaml",
			},
		})
	end)
end

local function setup_enhancements()
	safe("nvim-surround", function()
		require("nvim-surround").setup({})
	end)

	vim.g.matchup_matchparen_offscreen = { method = "popup" }

	safe("which-key.nvim", function()
		require("which-key").setup({})
	end)
end

local function setup_rustaceanvim()
	if not regular_nvim then
		return
	end

	vim.g.rustaceanvim = {
		server = {
			settings = {
				["rust-analyzer"] = {
					cargo = {
						allFeatures = true,
						loadOutDirsFromCheck = true,
						buildScripts = {
							enable = true,
						},
					},
					checkOnSave = {
						allFeatures = true,
						command = "clippy",
						extraArgs = { "--no-deps" },
					},
					procMacro = {
						enable = true,
						ignored = {
							["async-trait"] = { "async_trait" },
							["napi-derive"] = { "napi" },
							["async-recursion"] = { "async_recursion" },
						},
					},
					inlayHints = {
						typeHints = { enable = true },
						parameterHints = { enable = true },
						chainingHints = { enable = false },
					},
				},
			},
			on_attach = function(client, bufnr)
				if client:supports_method("textDocument/inlayHint") then
					pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
				end
			end,
		},
	}
end

local function setup_metals()
	safe("nvim-metals", function()
		local metals = require("metals")
		local metals_config = metals.bare_config()
		metals_config.on_attach = function(client, bufnr)
			if client:supports_method("textDocument/inlayHint") then
				pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
			end
		end

		local group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "scala", "sbt", "java" },
			callback = function()
				metals.initialize_or_attach(metals_config)
			end,
			group = group,
		})
	end)
end

local function setup_copilot()
	if not regular_nvim then
		return
	end

	safe("copilot.lua", function()
		require("copilot").setup({
			suggestion = {
				enabled = true,
				auto_trigger = true,
				keymap = {
					accept = false,
				},
			},
			panel = { enabled = false },
		})
	end)

	vim.keymap.set("i", "<Tab>", function()
		if vim.fn.pumvisible() == 1 then
			return "<C-n>"
		end

		local suggestion = require("copilot.suggestion")
		if suggestion.is_visible() then
			suggestion.accept()
			return ""
		end

		return "<Tab>"
	end, {
		expr = true,
		replace_keycodes = true,
		desc = "Copilot / PUM / Indent",
	})
end

local function setup_sidekick()
	safe("snacks.nvim", function()
		require("snacks").setup({
			input = { enabled = true },
			picker = { enabled = true },
		})
	end)

	safe("sidekick.nvim", function()
		require("sidekick").setup({
			nes = { enabled = false },
			cli = {
				enabled = true,
				mux = {
					backend = "tmux",
					enabled = "true",
					create = "split",
					split = {
						axis = "vertical",
						size = 0.3,
					},
				},
			},
		})
	end)

	vim.keymap.set("n", "<leader>oo", function()
		require("sidekick.cli").toggle()
	end, { desc = "AI: Toggle Chat" })
	vim.keymap.set("x", "<leader>oa", function()
		local start_pos = vim.fn.getpos("v")
		local end_pos = vim.fn.getpos(".")
		local start_row, start_col = start_pos[2] - 1, start_pos[3] - 1
		local end_row, end_col = end_pos[2] - 1, end_pos[3]

		if end_row < start_row or (end_row == start_row and end_col < start_col) then
			start_row, end_row = end_row, start_row
			start_col, end_col = end_col, start_col
		end

		local file = vim.api.nvim_buf_get_name(0)
		if file == "" then
			return
		end

		local rel = vim.fn.fnamemodify(file, ":.")
		local start_line = start_row + 1
		local end_line = end_row + 1
		local ref = string.format("@%s:%d-%d", rel, start_line, end_line)
		require("sidekick.cli").send({ msg = ref })
	end, { desc = "Send Visual Selection" })
	vim.keymap.set("n", "<leader>oa", function()
		local word = vim.fn.expand("<cword>")
		local file = vim.api.nvim_buf_get_name(0)
		if file == "" then
			return
		end
		local rel = vim.fn.fnamemodify(file, ":.")
		local line = vim.api.nvim_win_get_cursor(0)[1]
		local ref = string.format("@%s:%d-%d", rel, line, line)
		require("snacks").input({ prompt = "Ask AI about '" .. word .. "': " }, function(input)
			if not input then
				return
			end
			require("sidekick.cli").send({ msg = input .. "\n\nContext: " .. ref })
		end)
	end, { desc = "AI: Ask (Word)" })
	vim.keymap.set("n", "<leader>af", function()
		require("snacks").input({ prompt = "Instruction for this file: " }, function(input)
			if not input then
				return
			end
			require("sidekick.cli").send({ msg = input .. "\n\nFile Context:\n{file}" })
		end)
	end, { desc = "AI: Send Whole File" })
end

function M.init()
	if regular_nvim then
		vim.g.tmux_navigator_no_mappings = 1
	end

	vim.o.timeout = true
	vim.o.timeoutlen = 300
end

function M.setup()
	setup_theme()
	setup_statusline()
	setup_oil()
	setup_nvim_tree()
	setup_fzf_lua()
	setup_tmux_navigator()
	setup_gitsigns()
	setup_fugitive()
	setup_treesitter()
	setup_enhancements()
	setup_rustaceanvim()
	setup_metals()
	setup_copilot()
	setup_sidekick()
end

return M
