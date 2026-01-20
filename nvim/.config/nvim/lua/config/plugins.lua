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
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			-- Normal Mode
			{ "<leader>f", "<cmd>FzfLua files<cr>", desc = "Find Files" },
			{ "<leader>F", "<cmd>FzfLua git_files<cr>", desc = "Find Git Files" },
			{ "<leader>g", "<cmd>FzfLua live_grep<cr>", desc = "Exact Grep" },
			{ "<leader>G", "<cmd>FzfLua grep_project<cr>", desc = "Fuzzy Grep" },
			{ "<leader>w", "<cmd>FzfLua grep_cword<cr>", desc = "Grep Word Under Cursor" },
			{ "<leader>b", "<cmd>FzfLua buffers<cr>", desc = "Find Buffers" },
			{ "<leader>t", "<cmd>FzfLua btags<cr>", desc = "Buffer Tags" },
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
			-- Optional: setup fzf-lua with defaults if you want to customize icons/layout later
			require("fzf-lua").setup({ "default-title" })
            -- This sets the keys only when an LSP attaches to a buffer
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("FzfLspConfig", { clear = true }),
                callback = function(ev)
                    local opts = { buffer = ev.buf, silent = true }

                    -- Replace "Find References" (Default: grr)
                    vim.keymap.set("n", "grr", function()
                        fzf.lsp_references({ ignore_current_line = true })
                    end, { buffer = ev.buf, desc = "Fzf References" })

                    -- Replace "Go to Definition" (Default: gd)
                    vim.keymap.set("n", "gd", function()
                        fzf.lsp_definitions({ jump_to_single_result = true })
                    end, { buffer = ev.buf, desc = "Fzf Definitions" })

                    -- Replace "Go to Declaration" (Default: gD)
                    vim.keymap.set("n", "gD", function()
                        fzf.lsp_declarations({ jump_to_single_result = true })
                    end, { buffer = ev.buf, desc = "Fzf Declarations" })

                    -- Replace "Go to Implementation" (Default: gI)
                    vim.keymap.set("n", "gI", function()
                        fzf.lsp_implementations({ jump_to_single_result = true })
                    end, { buffer = ev.buf, desc = "Fzf Implementations" })

                    -- Replace "Type Definition" (Default: gy)
                    vim.keymap.set("n", "gy", function()
                        fzf.lsp_typedefs({ jump_to_single_result = true })
                    end, { buffer = ev.buf, desc = "Fzf Type Definitions" })

                    -- Replace "Code Actions" (Default: gra / <leader>ca)
                    vim.keymap.set({ "n", "v" }, "<leader>ca", function()
                        fzf.lsp_code_actions()
                    end, { buffer = ev.buf, desc = "Fzf Code Actions" })

                    -- Note: We map <leader>ca here generally.
                    -- If you want to replace the new default 'gra' as well:
                    vim.keymap.set({ "n", "v" }, "gra", function()
                        fzf.lsp_code_actions()
                    end, { buffer = ev.buf, desc = "Fzf Code Actions" })
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
                map('n', ']c', function()
                    if vim.wo.diff then return ']c' end
                    vim.schedule(function() gs.next_hunk() end)
                    return '<Ignore>'
                end, {expr=true})
                map('n', '[c', function()
                    if vim.wo.diff then return '[c' end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                end, {expr=true})
                map('n', '<leader>hp', gs.preview_hunk)
            end,
		},
	},
	{
		"tpope/vim-fugitive",
		enabled = not vim.g.vscode,
		cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
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
	{ "andymass/vim-matchup", event = "BufReadPost" },
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

					-- 2. Setup Terminal (The Chat Window)
					terminal = { enabled = true },

					-- 3. Setup Picker (The Actions Menu)
					picker = {
						enabled = true, -- Enable Snacks to handle standard menus
						ui_select = true, -- Explicitly tell it to handle vim.ui.select
						win = {
							input = {
								keys = {
									-- FORCE Ctrl+q to close the window (instead of Quickfix)
									["<C-q>"] = { "close", mode = { "n", "i" } },
								},
							},
						},
					},
				},
			},
		},
		config = function()
			require("fzf-lua").register_ui_select()

			---@type opencode.Opts
			vim.g.opencode_opts = {
				preferred_picker = "fzf",

				-- Use Snacks for the terminal window integration
				provider = {
					enabled = "snacks",
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
}
