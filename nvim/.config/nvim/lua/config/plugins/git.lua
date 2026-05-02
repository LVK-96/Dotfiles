local M = {}

local lazy = require("config.plugins.lazy")
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

local function configure_gitsigns()
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
end

local function setup_gitsigns()
	lazy.on_event({ "BufReadPre", "BufNewFile" }, "gitsigns.nvim", configure_gitsigns)
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

local function configure_codediff()
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
end

local function configure_neogit()
	lazy.setup_once("codediff.nvim", configure_codediff)
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
end

local function open_neogit(args)
	local parse_command_args = require("neogit.lib.util").parse_command_args
	require("neogit").open(parse_command_args(args or {}))
end

local function install_neogit_command()
	vim.api.nvim_create_user_command("Neogit", function(opts)
		lazy.run("neogit", configure_neogit, function()
			open_neogit(opts.fargs)
		end)
	end, {
		nargs = "*",
		desc = "Open Neogit",
		force = true,
		complete = function(arglead)
			lazy.setup_once("neogit", configure_neogit)
			return require("neogit").complete(arglead)
		end,
	})
end

local function open_neogit_log()
	require("neogit").action("log", "log_current", { "--graph", "--decorate", "--color" })()
end

local function setup_neogit()
	install_neogit_command()
	vim.api.nvim_create_autocmd("VimEnter", {
		group = vim.api.nvim_create_augroup("UserNeogitCommand", { clear = true }),
		once = true,
		callback = install_neogit_command,
	})

	lazy.map("n", "<leader>gs", "neogit", configure_neogit, function()
		open_neogit()
	end, { desc = "Neogit Status" })
	lazy.map("n", "<leader>gn", "neogit", configure_neogit, function()
		open_neogit()
	end, { desc = "Neogit Status" })
	lazy.map("n", "<leader>glg", "neogit", configure_neogit, open_neogit_log, { desc = "Neogit Log" })
end

function M.setup()
	setup_gitsigns()
	setup_neogit_diff_matches()
	setup_neogit()
end

return M
