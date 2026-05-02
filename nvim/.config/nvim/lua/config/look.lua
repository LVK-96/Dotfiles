local M = {}

function M.setup()
	vim.opt.termguicolors = true
	vim.opt.pumheight = 10
	vim.opt.completeopt = { "menu", "menuone", "noselect" }
	vim.opt.fillchars = { eob = " " } -- hide "~" on empty lines

	-- Highlight comments as italic.
	vim.api.nvim_set_hl(0, "Comment", { italic = true, force = true })

	vim.opt.laststatus = 2
	require("config.numbered_tabline").setup()
end

return M
