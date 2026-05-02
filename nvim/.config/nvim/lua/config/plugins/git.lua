local M = {}

local util = require("config.plugins.util")

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

local function setup_gitsigns()
	util.safe("gitsigns.nvim", function()
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
	vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git Blame" })
	vim.keymap.set("n", "<leader>glg", "<cmd>Git log --oneline --decorate --graph<CR>", { desc = "Git Log (Simple)" })
end

local function apply_codediff_highlights()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = true })
	local normal_fg = normal and normal.fg or nil
	local diff_highlights = util.diff_highlights

	vim.api.nvim_set_hl(0, "CodeDiffLineInsert", { fg = normal_fg, bg = diff_highlights.line_insert })
	vim.api.nvim_set_hl(0, "CodeDiffLineDelete", { fg = normal_fg, bg = diff_highlights.line_delete })
	vim.api.nvim_set_hl(0, "CodeDiffCharInsert", { fg = normal_fg, bg = diff_highlights.char_insert })
	vim.api.nvim_set_hl(0, "CodeDiffCharDelete", { fg = normal_fg, bg = diff_highlights.char_delete })
end

local function setup_codediff()
	util.safe("codediff.nvim", function()
		require("codediff").setup({
			highlights = {
				line_insert = "DiffAdd",
				line_delete = "DiffDelete",
				char_insert = util.diff_highlights.char_insert,
				char_delete = util.diff_highlights.char_delete,
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
	util.safe("neogit", function()
		util.setup_neogit_highlights()

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

function M.setup()
	setup_gitsigns()
	setup_fugitive()
	setup_codediff()
	setup_neogit_diff_matches()
	setup_neogit()
end

return M
