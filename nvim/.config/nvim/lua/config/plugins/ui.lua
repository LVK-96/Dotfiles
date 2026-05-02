local M = {}

local util = require("config.plugins.util")

local function setup_statusline()
	util.safe("mini.statusline", function()
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
	util.safe("nvim-solarized-lua", function()
		vim.o.background = "light"
		vim.cmd.colorscheme("solarized")
		util.setup_diff_highlights()
		util.setup_neogit_highlights()

		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("UserDiffHighlights", { clear = true }),
			callback = function()
				util.setup_diff_highlights()
				util.setup_neogit_highlights()
			end,
		})
	end)
end

local function setup_snacks()
	util.safe("snacks.nvim", function()
		require("snacks").setup({
			input = { enabled = true },
			picker = { enabled = true },
		})
	end)
end

local function setup_enhancements()
	vim.g.matchup_matchparen_offscreen = { method = "popup" }

	util.safe("which-key.nvim", function()
		require("which-key").setup({})
	end)
end

function M.setup()
	setup_theme()
	setup_statusline()
	setup_snacks()
	setup_enhancements()
end

return M
