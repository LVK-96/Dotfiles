return {
	-- Theme
	-- { "ishan9299/nvim-solarized-lua",
	--     enabled = not vim.g.vscode,
	--     lazy = false,
	--     priority = 1000,
	--     config = function()
	--         vim.o.background = "light" -- or "light"
	--         vim.cmd.colorscheme("solarized")
	--     end,
	-- },
	{
		"miikanissi/modus-themes.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.o.background = "dark" -- or "light"
			vim.cmd.colorscheme("modus_vivendi")
		end,
	},

	--Statusline
	{
		"nvim-mini/mini.statusline",
		version = false,
		config = function()
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
		end,
	},

	-- Navigation
	{
		"stevearc/oil.nvim",
		enabled = not vim.g.vscode,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = { "Oil" },
		keys = { { "-", "<CMD>Oil<CR>", desc = "Open Parent Directory" } },
		win_options = { signcolumn = "yes:2" },
		config = function()
			require("oil").setup({
				-- 1. REPLICATE 'netrw_bufsettings = ... renu'
				-- This enables Relative Numbers inside the file explorer
				win_options = {
					signcolumn = "yes",
					number = true,
					relativenumber = true, -- This matches your 'renu'

					cursorline = true,
				},

				-- 2. REPLICATE 'netrw_banner = 0'
				-- Oil doesn't have a banner by default, but we can disable
				-- the "Sort" headers to make it cleaner.
				view_options = {
					show_hidden = true,
					natural_order = true,
					is_always_hidden = function(name)
						return name == ".." or name == ".git"
					end,
				},

				-- Oil handles its buffers efficiently, but this ensures
				-- deleted buffers don't hang around too long.
				cleanup_delay_ms = 2000,

				keymaps = {
					["g?"] = "actions.show_help",
					["<CR>"] = "actions.select",
					["<C-s>"] = "actions.select_vsplit",
					["<C-h>"] = "actions.select_split",
					["-"] = "actions.parent",
					["_"] = "actions.open_cwd",
				},

				-- Skip confirmation for simple deletes/moves
				skip_confirm_for_simple_edits = true,
			})

			-- Automatically wipe buffers for files that were deleted via Oil
			vim.api.nvim_create_autocmd("User", {
				pattern = "OilActionsPost",
				callback = function(args)
					if args.data.err then
						return
					end
					for _, action in ipairs(args.data.actions) do
						if action.type == "delete" then
							-- Depending on Oil version, the URL might be 'oil:///path' or just '/path'
							-- We extract the simple path to find the matching buffer
							local _, path = require("oil.util").parse_url(action.url)
							local buf = vim.fn.bufnr(path)
							if buf ~= -1 and vim.api.nvim_buf_is_valid(buf) then
								-- Force wipe the buffer (bdelete!)
								vim.api.nvim_buf_delete(buf, { force = true })
							end
						end
					end
				end,
			})
			-- Create the :Ex command to alias to :Oil
			vim.api.nvim_create_user_command("Ex", "Oil", {})
		end,
	},
	{
		"refractalize/oil-git-status.nvim",
		dependencies = {
			"stevearc/oil.nvim",
		},

		config = true,
	},
	{
		"nvim-tree/nvim-tree.lua",
		cmd = { "NvimTreeToggle", "NvimTreeFocus" },
		keys = {
			{ "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file tree" },
		},
		opts = {
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
		},
	},
	{
		"ibhagwan/fzf-lua",
		event = "LspAttach",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			-- Normal Mode
			{
				"<leader>f",
				function()
					require("fzf-lua").files({ multi = true })
				end,
				desc = "Find Files",
			},
			{
				"<leader>F",
				function()
					require("fzf-lua").git_files({ multi = true })
				end,
				desc = "Find Git Files",
			},
			{
				"<leader>gg",
				function()
					require("fzf-lua").live_grep({ multi = true })
				end,
				desc = "Live Grep",
			},
			{
				"<leader>gG",
				function()
					require("fzf-lua").grep({ multi = true })
				end,
				desc = "Grep",
			},
			{
				"<leader>gf",
				function()
					require("fzf-lua").grep_project({ multi = true })
				end,
				desc = "Fuzzy Grep",
			},
			{
				"<leader>gw",
				function()
					require("fzf-lua").grep_cword({ multi = true })
				end,
				desc = "Grep Word Under Cursor",
			},
			{
				"<leader>b",
				function()
					require("fzf-lua").buffers({ multi = true })
				end,
				desc = "Find Buffers",
			},
			{
				"<leader>t",
				function()
					require("fzf-lua").btags({ multi = true })
				end,
				desc = "Buffer Tags",
			},
			{ "<leader><tab>", "<cmd>FzfLua keymaps<cr>", desc = "Search Keymaps" },

			-- Insert Mode (Completions)
			-- <c-x><c-k> (Word completion) is skipped; native <C-n> is usually better.
			{
				"<c-x><c-f>",
				function()
					require("fzf-lua").complete_path()
				end,
				mode = "i",
				desc = "Complete Path",
			},
			{
				"<c-x><c-l>",
				function()
					require("fzf-lua").complete_line()
				end,
				mode = "i",
				desc = "Complete Line",
			},
			{
				"<c-x><c-j>",
				function()
					require("fzf-lua").complete_file()
				end,
				mode = "i",
				desc = "Complete File",
			},
		},
		config = function()
			local function get_git_root()
				local git_dir = vim.fn.finddir(".git", ".;")
				if git_dir ~= "" then
					return vim.fn.fnamemodify(git_dir, ":h")
				end
				return vim.loop.cwd()
			end

			local git_root = get_git_root()
			require("fzf-lua").setup({
				defaults = {
					cwd = git_root,
				},
				files = {
					cwd_prompt = false,
					fd_opts = "--type f --hidden --follow --exclude .git",
				},
				grep = {
					rg_opts = "--hidden --smart-case --column --line-number --no-heading --color=never --glob '!.git/*'",
				},
				live_grep = {
					rg_opts = "--hidden --smart-case --column --line-number --no-heading --color=never --glob '!.git/*'",
				},
			})
			require("fzf-lua").register_ui_select()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("FzfLspConfig", { clear = true }),
				callback = function(ev)
					local opts = { buffer = ev.buf, silent = true }

					-- Replace "Find References" (Default: grr)
					vim.keymap.set("n", "grr", function()
						require("fzf-lua").lsp_references({ ignore_current_line = true, multi = true })
					end, { buffer = ev.buf, desc = "Fzf References" })

					-- Replace "Go to Definition" (Default: gd)
					vim.keymap.set("n", "gd", function()
						require("fzf-lua").lsp_definitions({ jump1 = true })
					end, { buffer = ev.buf, desc = "Fzf Definitions" })

					-- Replace "Go to Declaration" (Default: gD)
					vim.keymap.set("n", "gD", function()
						require("fzf-lua").lsp_declarations({ jump1 = true })
					end, { buffer = ev.buf, desc = "Fzf Declarations" })

					-- Replace "Go to Implementation" (Default: gI)
					vim.keymap.set("n", "gI", function()
						require("fzf-lua").lsp_implementations({ jump1 = true })
					end, { buffer = ev.buf, desc = "Fzf Implementations" })

					-- Replace "Type Definition" (Default: gy)
					vim.keymap.set("n", "gy", function()
						require("fzf-lua").lsp_typedefs({ jump1 = true })
					end, { buffer = ev.buf, desc = "Fzf Type Definitions" })

					-- Replace "Code Actions" (Default: gra / <leader>ca)
					vim.keymap.set({ "n", "v" }, "<leader>ca", function()
						require("fzf-lua").lsp_code_actions({ multi = true })
					end, { buffer = ev.buf, desc = "Fzf Code Actions" })

					-- Note: We map <leader>ca here generally.
					-- If you want to replace the new default 'gra' as well:
					vim.keymap.set({ "n", "v" }, "gra", function()
						require("fzf-lua").lsp_code_actions({ multi = true })
					end, { buffer = ev.buf, desc = "Fzf Code Actions" })

					-- Disable inlay hints in insert mode (workaround for neovim #36318)
					-- These should only apply if the hints are on in the first place
					vim.api.nvim_create_autocmd("InsertEnter", {
						buffer = ev.buf,
						callback = function()
							local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
							vim.b[ev.buf].inlay_hints_was_enabled = is_enabled
							if is_enabled then
								vim.lsp.inlay_hint.enable(false, { bufnr = ev.buf })
							end
						end,
					})
					vim.api.nvim_create_autocmd("InsertLeave", {
						buffer = ev.buf,
						callback = function()
							if vim.b[ev.buf].inlay_hints_was_enabled then
								vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
							end
						end,
					})
					vim.api.nvim_create_autocmd("InsertLeave", {
						buffer = ev.buf,
						callback = function()
							if vim.b[ev.buf].inlay_hints_was_enabled then
								vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
							end
						end,
					})
				end,
			})
		end,
	},
	{
		"christoomey/vim-tmux-navigator",
		enabled = not vim.g.vscode,
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
			"TmuxNavigatorProcessList",
		},
		keys = {
			{ "<C-a>h", "<cmd>TmuxNavigateLeft<cr>" },
			{ "<C-a>j", "<cmd>TmuxNavigateDown<cr>" },
			{ "<C-a>k", "<cmd>TmuxNavigateUp<cr>" },
			{ "<C-a>l", "<cmd>TmuxNavigateRight<cr>" },
			{ "<C-a>\\", "<cmd>TmuxNavigatePrevious<cr>" },
		},
		init = function()
			-- Disable the default mappings so they don't conflict
			vim.g.tmux_navigator_no_mappings = 1
		end,
	},

	-- Git
	{
		"lewis6991/gitsigns.nvim",
		enabled = not vim.g.vscode,
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			-- Mimic vim-gitgutter symbols
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
				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end
				-- Navigation Keybinds
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
		},
	},
	{
		"tpope/vim-fugitive",
		enabled = not vim.g.vscode,
		cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
		keys = {
			{ "<leader>gs", vim.cmd.Git, desc = "Git Status" },
			{ "<leader>gb", "<cmd>Git blame<CR>", desc = "Git Blame" },
			{ "<leader>glg", "<cmd>Git log --oneline --decorate --graph<CR>", desc = "Git Log (Simple)" },
		},
	},
	"sindrets/diffview.nvim",
	-- This ensures the plugin only loads when one of these commands is run
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
		"DiffviewRefresh",
	},
	opts = {
		enhanced_diff_hl = true,
		use_icons = true,
		view = {
			merge_tool = {
				layout = "diff3_mixed",
			},
		},
	},

	-- Misc
	{
		"nvim-treesitter/nvim-treesitter",
		enabled = not vim.g.vscode,
		event = { "BufReadPost", "BufNewFile" },
		build = ":TSUpdate",
		config = function()
			-- This tries to load the module. If it fails (because it's not installed yet),
			-- it returns 'false' instead of crashing Neovim.
			local status_ok, configs = pcall(require, "nvim-treesitter.configs")
			-- If the plugin isn't found, stop here seamlessly
			if not status_ok then
				return
			end

			require("nvim-treesitter.configs").setup({
				-- Install parsers synchronously (only applied to `ensure_installed`)
				sync_install = false,
				-- Automatically install missing parsers when entering buffer
				auto_install = true,
				highlight = {
					enable = true, -- REQUIRED for syntax highlighting
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
		end,
	},

	-- Enhancements
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = true,
	},
	{
		"andymass/vim-matchup",
		event = "BufReadPost",
		config = function()
			-- Use treesitter's engine for matching (faster than regex)
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300 -- Show popup after 300ms
		end,
		opts = {}, -- Uses default setup
	},

	-- Language specific
	{
		"mrcjkb/rustaceanvim",
		enabled = not vim.g.vscode,
		version = "^6", -- Recommended
		lazy = false, -- This plugin is already lazy
		config = function()
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
							-- Add clippy lints for Rust.
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
		end,
	},
	{
		"scalameta/nvim-metals",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"mfussenegger/nvim-dap",
		},
		ft = { "scala", "sbt", "java" },
		config = function()
			local metals = require("metals")
			local metals_config = metals.bare_config()
			metals_config.on_attach = function(client, bufnr)
				metals.setup_dap()
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
		end,
	},

	-- LSP
	{
		"williamboman/mason.nvim",
		enabled = not vim.g.vscode,
		cmd = "Mason",
		config = true, -- Runs require("mason").setup()
	},
	{
		"neovim/nvim-lspconfig",
		enabled = not vim.g.vscode,
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
		config = function()
			-- Setup Mason
			require("mason").setup()
			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						-- Note: We intentionally leave this empty now!
						-- We don't need to configure completion here anymore.
						require("lspconfig")[server_name].setup({})
					end,
				},
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					-- Enable native autocomplete for this server
					if client:supports_method("textDocument/completion") then
						vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
					end
				end,
			})

			vim.diagnostic.config({
				virtual_text = false, -- Turn off inline diagnostics
				signs = true, -- Keep gutter signs (icons on the left)
				underline = true,
				update_in_insert = false,
				float = {
					source = "always",
				},
			})

			-- Show diagnostics in a floating window on hover (CursorHold)
			vim.api.nvim_create_autocmd("CursorHold", {
				callback = function()
					local opts = {
						focusable = false,
						close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
						source = "always",
						prefix = " ",
						scope = "cursor",
					}
					vim.diagnostic.open_float(nil, opts)
				end,
			})
		end,
	},

	-- AI
	{
		"zbirenbaum/copilot.lua",
		enabled = not vim.g.vscode,
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true, -- This makes it show up automatically
					keymap = {
						accept = false, -- Disable default so we can map Tab manually below
					},
				},
				panel = { enabled = false },
			})
		end,
		keys = {
			{
				"<Tab>",
				function()
					-- 1. If the built-in popup menu is visible (LSP/Omnifunc), cycle down
					if vim.fn.pumvisible() == 1 then
						return "<C-n>"
					end

					-- 2. If Copilot has a suggestion, accept it
					local suggestion = require("copilot.suggestion")
					if suggestion.is_visible() then
						suggestion.accept()
						return ""
					end

					-- 3. Otherwise, perform a normal Tab indent
					return "<Tab>"
				end,
				mode = "i",
				expr = true, -- Required because we return strings like "<C-n>" or "<Tab>"
				replace_keycodes = true,
				desc = "Copilot / PUM / Indent",
			},
		},
	},
	{
		"NickvanDyke/opencode.nvim",
		enabled = os.getenv("NVIM_AI") == "opencode",
		keys = {
			{
				"<leader>oo",
				function()
					require("opencode").toggle()
				end,
				desc = "AI: Toggle",
			},
			{
				"<leader>oa",
				function()
					require("opencode").ask("@this: ", { submit = true })
				end,
				mode = { "n", "x" },
				desc = "AI: Ask",
			},
			{
				"<leader>af",
				function()
					require("opencode").ask("@file: ", { submit = true })
				end,
				desc = "AI: Send Whole File",
			},
			{
				"<leader>ox",
				function()
					require("opencode").select()
				end,
				mode = { "n", "x" },
				desc = "AI: Actions",
			},
			{
				"go",
				function()
					return require("opencode").operator("@this ")
				end,
				mode = { "n", "x" },
				expr = true,
				desc = "AI: Operator",
			},
			{
				"goo",
				function()
					return require("opencode").operator("@this ") .. "_"
				end,
				expr = true,
				desc = "AI: Line",
			},
			{
				"<C-S-u>",
				function()
					require("opencode").command("session.half.page.up")
				end,
				mode = { "n", "i" },
				desc = "AI: Scroll Up",
			},
			{
				"<C-S-d>",
				function()
					require("opencode").command("session.half.page.down")
				end,
				mode = { "n", "i" },
				desc = "AI: Scroll Down",
			},
			{
				"<leader>om",
				function()
					require("opencode").command("agent.cycle")
				end,
				desc = "AI: Cycle Model",
			},
		},
		dependencies = {
			{
				"folke/snacks.nvim",
				opts = {
					-- 1. Setup Input (The Prompt Box)
					input = {
						enabled = true,
						keys = { ["<C-q>"] = { "cancel", mode = { "n", "i" } } },
					},
				},
			},
		},
		init = function()
			---@type opencode.Opts
			vim.g.opencode_opts = {
				preferred_picker = "fzf",

				-- Use tmux for the terminal window integration
				provider = {
					enabled = "tmux",
					tmux = {
						options = "-h",
					},
				},

				-- Your Antigravity Model Setup
				agent = {
					auto_init = true,
					default_model = "google/antigravity-gemini-3-flash",
				},

				-- Floating Window Style
				ui = {
					style = "float",
					width = 0.8,
					height = 0.8,
				},
			}

			-- Required for `opts.events.reload`.
			vim.o.autoread = true
		end,
	},
	{
		"folke/sidekick.nvim",
		enabled = os.getenv("NVIM_AI") == "sidekick",
		event = "VeryLazy",
		dependencies = {
			{
				"folke/snacks.nvim",
				opts = {
					-- This tells Snacks to takeover vim.ui.input
					input = { enabled = true },
					-- Optional: Makes vim.ui.select (menus) nice too
					picker = { enabled = true },
				},
			},
		},
		cmd = { "Sidekick" },
		opts = {
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
		},
		keys = {
			-- Toggle Chat
			{
				"<leader>oo",
				function()
					require("sidekick.cli").toggle()
				end,
				desc = "AI: Toggle Chat",
			},

			-- [Ask Selection] - Sends the visual selection directly
			{
				"<leader>oa",
				function()
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
				end,
				mode = "x",
				desc = "Send Visual Selection",
			},

			-- [Ask Word] - Uses Snacks for a nice single-line popup
			{
				"<leader>oa",
				function()
					local word = vim.fn.expand("<cword>")
					require("snacks").input({ prompt = "Ask AI about '" .. word .. "': " }, function(input)
						if not input then
							return
						end
						require("sidekick.cli").send({ msg = input .. "\n\nContext: " .. word })
					end)
				end,
				mode = "n",
				desc = "AI: Ask (Word)",
			},

			-- [Send File] - Uses Snacks for a nice single-line popup
			{
				"<leader>af",
				function()
					require("snacks").input({ prompt = "Instruction for this file: " }, function(input)
						if not input then
							return
						end
						require("sidekick.cli").send({ msg = input .. "\n\nFile Context:\n{file}" })
					end)
				end,
				desc = "AI: Send Whole File",
			},
		},
	},
}
