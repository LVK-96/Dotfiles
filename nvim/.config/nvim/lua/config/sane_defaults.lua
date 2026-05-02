local M = {}

function M.setup()
	local vscode = require("config.vscode")

	-- Indentation
	vim.opt.tabstop = 4
	vim.opt.shiftwidth = 4
	vim.opt.softtabstop = 4
	vim.opt.expandtab = true
	vim.opt.autoindent = true
	vim.opt.smartindent = true

	-- UI Config
	vim.opt.shortmess:append("I")
	if not vscode.enabled() then
		vim.opt.number = true
		vim.opt.relativenumber = true
		vim.opt.scrolloff = 10
		vim.opt.sidescrolloff = 10
		vim.opt.listchars = { tab = "> ", trail = "-", extends = ">", precedes = "<", nbsp = "+" }
		vim.opt.laststatus = 2 -- Always show statusline
	end

	-- Search
	vim.opt.ignorecase = true
	vim.opt.smartcase = true
	vim.opt.gdefault = true -- Adds 'g' flag to search/replace by default
	vim.opt.hlsearch = true
	vim.opt.incsearch = true

	-- System
	vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
	vim.opt.updatetime = 100 -- Faster completion/triggering
	vim.opt.timeoutlen = 1000 -- Time to wait for a mapped sequence to complete
	vim.opt.autoread = true -- auto-reload changes if outside of neovim
	vim.opt.autowrite = false -- do not auto-save

	-- Undo (Keep persistent undo)
	vim.opt.undofile = true

	-- Window Splitting
	vim.opt.splitright = true
	vim.opt.splitbelow = true

	-- Session Management
	vim.opt.sessionoptions:remove("options")
	vim.opt.viewoptions:remove("options")

	-- Formatting
	vim.opt.formatoptions:append("j") -- Remove comment leader when joining lines
end

return M
