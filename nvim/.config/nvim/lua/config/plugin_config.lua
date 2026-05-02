local M = {}

local regular_nvim = not require("config.vscode").enabled()

function M.init()
	if regular_nvim then
		vim.g.tmux_navigator_no_mappings = 1
	end

	vim.o.timeout = true
	vim.o.timeoutlen = 300
end

function M.setup()
	if regular_nvim then
		require("config.plugins.ui").setup()
		require("config.plugins.navigation").setup()
	end

	require("config.plugins.editing").setup({ completion = regular_nvim })

	if regular_nvim then
		require("config.plugins.git").setup()
		require("config.plugins.languages").setup()
		require("config.plugins.ai").setup()
	end
end

return M
