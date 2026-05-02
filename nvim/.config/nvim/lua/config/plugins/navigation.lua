local M = {}

local util = require("config.plugins.util")

local function setup_fyler()
	util.safe("fyler.nvim", function()
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

	util.safe("fzf-lua", function()
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
	end)

	util.safe("fzf-lua-frecency.nvim", function()
		require("fzf-lua-frecency").setup()
	end)

	util.safe("fzf-lua-lsp", function()
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

local function setup_navigation_extras()
	util.safe("grug-far.nvim", function()
		require("grug-far").setup({})
	end)

	vim.keymap.set({ "n", "x" }, "<leader>sr", function()
		require("grug-far").open()
	end, { desc = "Search and Replace" })

	util.safe("todo-comments.nvim", function()
		require("todo-comments").setup({
			signs = false,
			highlight = {
				before = "",
				keyword = "wide_fg",
				after = "empty",
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

	util.safe("trouble.nvim", function()
		require("trouble").setup({})
	end)

	vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics (Trouble)" })
	vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", {
		desc = "Buffer Diagnostics (Trouble)",
	})
	vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<CR>", { desc = "Location List (Trouble)" })
	vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>", { desc = "Quickfix List (Trouble)" })

	util.safe("flash.nvim", function()
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

local function setup_tmux_navigator()
	vim.keymap.set("n", "<C-a>h", "<cmd>TmuxNavigateLeft<cr>")
	vim.keymap.set("n", "<C-a>j", "<cmd>TmuxNavigateDown<cr>")
	vim.keymap.set("n", "<C-a>k", "<cmd>TmuxNavigateUp<cr>")
	vim.keymap.set("n", "<C-a>l", "<cmd>TmuxNavigateRight<cr>")
	vim.keymap.set("n", "<C-a>\\", "<cmd>TmuxNavigatePrevious<cr>")
end

function M.setup()
	setup_fyler()
	setup_fzf_lua()
	setup_navigation_extras()
	setup_tmux_navigator()
end

return M
