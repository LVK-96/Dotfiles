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

local diff_highlights = {
	line_insert = "#e5e3b6",
	line_delete = "#f8d9c8",
	char_insert = "#d9dda3",
	char_delete = "#f0c0ad",
}

local function setup_diff_highlights()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = true })
	local fallback_fg = normal and normal.fg or nil

	vim.api.nvim_set_hl(0, "DiffAdd", { fg = fallback_fg, bg = diff_highlights.line_insert })
	vim.api.nvim_set_hl(0, "DiffDelete", { fg = fallback_fg, bg = diff_highlights.line_delete })
end

local function setup_neogit_highlights()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = true })
	local normal_fg = normal and normal.fg or nil
	local delete_fg = "#9f2d20"
	local add_fg = "#00856f"

	vim.api.nvim_set_hl(0, "NeogitDiffAdd", { fg = add_fg, bg = diff_highlights.line_insert })
	vim.api.nvim_set_hl(0, "NeogitDiffAddHighlight", { fg = add_fg, bg = diff_highlights.line_insert })
	vim.api.nvim_set_hl(0, "NeogitDiffAddCursor", { fg = add_fg, bg = diff_highlights.line_insert })
	vim.api.nvim_set_hl(0, "NeogitDiffDelete", { fg = delete_fg, bg = diff_highlights.line_delete })
	vim.api.nvim_set_hl(0, "NeogitDiffDeleteHighlight", { fg = delete_fg, bg = diff_highlights.line_delete })
	vim.api.nvim_set_hl(0, "NeogitDiffDeleteCursor", { fg = delete_fg, bg = diff_highlights.line_delete })
	vim.api.nvim_set_hl(0, "NeogitDiffAddInline", { fg = normal_fg, bg = diff_highlights.char_insert, bold = true })
	vim.api.nvim_set_hl(0, "NeogitDiffDeleteInline", { fg = normal_fg, bg = diff_highlights.char_delete, bold = true })
	vim.api.nvim_set_hl(0, "NeogitChangeDeleted", { fg = delete_fg, bold = true, italic = true })
	vim.api.nvim_set_hl(0, "NeogitChangeDstaged", { fg = delete_fg, bold = true, italic = true })
	vim.api.nvim_set_hl(0, "NeogitChangeDunstaged", { fg = delete_fg, bold = true, italic = true })
	vim.api.nvim_set_hl(0, "NeogitChangeDuntracked", { fg = delete_fg, bold = true, italic = true })
end

local function add_neogit_diff_matches()
	if not vim.bo.filetype:match("^Neogit") or vim.w.user_neogit_diff_matches then
		return
	end

	vim.w.user_neogit_diff_matches = {
		vim.fn.matchadd("NeogitDiffDelete", [[^-.*]], 300),
		vim.fn.matchadd("NeogitDiffAdd", [[^+.*]], 300),
	}
end

local function setup_neogit_diff_matches()
	vim.api.nvim_create_autocmd({ "FileType", "WinEnter" }, {
		group = vim.api.nvim_create_augroup("UserNeogitDiffMatches", { clear = true }),
		callback = add_neogit_diff_matches,
	})
end

local function setup_theme()
	if not regular_nvim then
		return
	end

	safe("nvim-solarized-lua", function()
		vim.o.background = "light"
		vim.cmd.colorscheme("solarized")
		setup_diff_highlights()
		setup_neogit_highlights()

		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("UserDiffHighlights", { clear = true }),
			callback = function()
				setup_diff_highlights()
				setup_neogit_highlights()
			end,
		})
	end)
end

local function setup_fyler()
	if not regular_nvim then
		return
	end

	safe("fyler.nvim", function()
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
	end)

	vim.keymap.set("n", "<leader>e", function()
		require("fyler").toggle({ kind = "split_left_most" })
	end, { desc = "Toggle file tree" })

	vim.keymap.set("n", "-", function()
		require("fyler").open({ kind = "float" })
	end, { desc = "Open file explorer" })

	vim.api.nvim_create_user_command("Ex", function()
		require("fyler").open({ kind = "replace" })
	end, { desc = "Open fyler float", force = true })
end

local function setup_fzf_lua()
	vim.keymap.set("n", "<leader>f", function()
		require("fzf-lua").files({ multi = true })
	end, { desc = "Find Files" })
	vim.keymap.set("n", "<leader>F", function()
		require("fzf-lua").git_files({ multi = true })
	end, { desc = "Find Git Files" })
	vim.keymap.set("n", "<leader>fr", function()
		require("fzf-lua-frecency").frecency({ cwd_only = true })
	end, { desc = "Find Frecent Files" })
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
	end)

	safe("fzf-lua-frecency.nvim", function()
		require("fzf-lua-frecency").setup()
	end)

	safe("fzf-lua-lsp", function()
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

local function setup_mini_modules()
	local mini_modules = {
		"ai",
		"align",
		"comment",
		"move",
		"operators",
		"pairs",
		"splitjoin",
	}

	for _, module in ipairs(mini_modules) do
		safe("mini." .. module, function()
			local mini_module = require("mini." .. module)
			mini_module.setup({})

			if module == "pairs" then
				vim.api.nvim_create_autocmd("FileType", {
					pattern = { "verilog", "systemverilog" },
					callback = function(ev)
						vim.keymap.set("i", "'", "'", { buffer = ev.buf })
					end,
				})
			end
		end)
	end

	safe("mini.snippets", function()
		local snippets = require("mini.snippets")
		snippets.setup({
			snippets = {
				snippets.gen_loader.from_lang(),
			},
		})
	end)
end

local function setup_navigation_extras()
	if not regular_nvim then
		return
	end

	safe("grug-far.nvim", function()
		require("grug-far").setup({})
	end)

	vim.keymap.set({ "n", "x" }, "<leader>sr", function()
		require("grug-far").open()
	end, { desc = "Search and Replace" })

	safe("todo-comments.nvim", function()
		require("todo-comments").setup({
			signs = false,
			highlight = {
				before = "", -- "fg" or "bg" or empty
				keyword = "wide_fg",
				after = "empty", -- "fg" or "bg" or empty
			},
		})
	end)

	vim.keymap.set("n", "]t", function()
		require("todo-comments").jump_next()
	end, { desc = "Next todo comment" })
	vim.keymap.set("n", "[t", function()
		require("todo-comments").jump_prev()
	end, { desc = "Previous todo comment" })
	vim.keymap.set("n", "<leader>xt", "<cmd>Trouble todo toggle<CR>", { desc = "Todos (Trouble)" })

	safe("trouble.nvim", function()
		require("trouble").setup({})
	end)

	vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics (Trouble)" })
	vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", {
		desc = "Buffer Diagnostics (Trouble)",
	})
	vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<CR>", { desc = "Location List (Trouble)" })
	vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>", { desc = "Quickfix List (Trouble)" })

	safe("flash.nvim", function()
		require("flash").setup({})
	end)

	vim.keymap.set({ "n", "x", "o" }, "s", function()
		require("flash").jump()
	end, { desc = "Flash" })
	vim.keymap.set({ "n", "x", "o" }, "S", function()
		require("flash").treesitter()
	end, { desc = "Flash Treesitter" })
	vim.keymap.set("o", "r", function()
		require("flash").remote()
	end, { desc = "Remote Flash" })
	vim.keymap.set({ "o", "x" }, "R", function()
		require("flash").treesitter_search()
	end, { desc = "Treesitter Search" })
	vim.keymap.set("c", "<C-s>", function()
		require("flash").toggle()
	end, { desc = "Toggle Flash Search" })
end

local function setup_blink_cmp()
	if not regular_nvim then
		return
	end

	safe("blink.cmp", function()
		local blink = require("blink.cmp")
		local build_ok, build_err = pcall(function()
			blink.build():wait(60000)
		end)
		if not build_ok then
			vim.schedule(function()
				vim.notify(
					"blink.cmp native build failed, continuing without native fuzzy: " .. tostring(build_err),
					vim.log.levels.WARN
				)
			end)
		end

		blink.setup({
			keymap = {
				preset = "none",
				["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
				["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide", "fallback" },
			},
			completion = {
				documentation = {
					auto_show = false,
				},
			},
			snippets = {
				preset = "mini_snippets",
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			fuzzy = {
				implementation = "prefer_rust_with_warning",
			},
		})
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
				delete = { text = "-" },
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
				map("n", "<leader>gb", "<cmd>Gitsigns blame<CR>", { desc = "Git Blame" })
			end,
		})
	end)
end

local function setup_fugitive()
	if not regular_nvim then
		return
	end

	vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git Blame" })
	vim.keymap.set("n", "<leader>glg", "<cmd>Git log --oneline --decorate --graph<CR>", { desc = "Git Log (Simple)" })
end

local function apply_codediff_highlights()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = true })
	local normal_fg = normal and normal.fg or nil

	vim.api.nvim_set_hl(0, "CodeDiffLineInsert", { fg = normal_fg, bg = diff_highlights.line_insert })
	vim.api.nvim_set_hl(0, "CodeDiffLineDelete", { fg = normal_fg, bg = diff_highlights.line_delete })
	vim.api.nvim_set_hl(0, "CodeDiffCharInsert", { fg = normal_fg, bg = diff_highlights.char_insert })
	vim.api.nvim_set_hl(0, "CodeDiffCharDelete", { fg = normal_fg, bg = diff_highlights.char_delete })
end

local function setup_codediff()
	safe("codediff.nvim", function()
		require("codediff").setup({
			highlights = {
				line_insert = "DiffAdd",
				line_delete = "DiffDelete",
				char_insert = diff_highlights.char_insert,
				char_delete = diff_highlights.char_delete,
			},
			close_on_open_in_prev_tab = false,
		})

		apply_codediff_highlights()
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("UserCodeDiffHighlights", { clear = true }),
			callback = apply_codediff_highlights,
		})
	end)
end

local function setup_neogit()
	if not regular_nvim then
		return
	end

	safe("neogit", function()
		setup_neogit_highlights()

		require("neogit").setup({
			diff_viewer = "codediff",
			treesitter_diff_highlight = true,
			integrations = {
				telescope = false,
				diffview = false,
				codediff = true,
				fzf_lua = true,
				mini_pick = false,
				snacks = true,
			},
		})
	end)

	vim.keymap.set("n", "<leader>gs", "<cmd>Neogit<CR>", { desc = "Neogit Status" })
	vim.keymap.set("n", "<leader>gn", "<cmd>Neogit<CR>", { desc = "Neogit Status" })
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

	vim.keymap.set("i", "<C-l>", function()
		local suggestion = require("copilot.suggestion")
		if suggestion.is_visible() then
			suggestion.accept()
			return ""
		end
	end)
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
		require("snacks").input({ prompt = "'" .. word .. "': " }, function(input)
			if not input then
				return
			end
			require("sidekick.cli").send({ msg = input .. "\n\nContext: " .. ref })
		end)
	end, { desc = "AI: Ask (Word)" })
	vim.keymap.set("n", "<leader>af", function()
		require("snacks").input({ prompt = "file: " }, function(input)
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
	setup_fyler()
	setup_fzf_lua()
	setup_mini_modules()
	setup_navigation_extras()
	setup_blink_cmp()
	setup_tmux_navigator()
	setup_gitsigns()
	setup_fugitive()
	setup_codediff()
	setup_neogit_diff_matches()
	setup_neogit()
	setup_treesitter()
	setup_enhancements()
	setup_rustaceanvim()
	setup_metals()
	setup_copilot()
	setup_sidekick()
end

return M
