local M = {}

local function disable_builtin_plugins()
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1
	vim.g.loaded_netrwSettings = 1
	vim.g.loaded_netrwFileHandlers = 1
	vim.g.loaded_matchit = 1
	vim.g.loaded_matchparen = 1
	vim.g.loaded_2html_plugin = 1
	vim.g.loaded_tohtml = 1
	vim.g.loaded_tutor_mode_plugin = 1
	vim.g.loaded_zipPlugin = 1
	vim.g.loaded_zip = 1
	vim.g.loaded_tarPlugin = 1
	vim.g.loaded_tar = 1
	vim.g.loaded_gzip = 1
	vim.g.loaded_spellfile_plugin = 1
	vim.g.loaded_rplugin = 1
end

local function disable_unused_providers()
	vim.g.loaded_python3_provider = 0
	vim.g.loaded_ruby_provider = 0
	vim.g.loaded_perl_provider = 0
	vim.g.loaded_node_provider = 0
end

function M.setup()
	vim.loader.enable()
	disable_builtin_plugins()
	disable_unused_providers()

	-- Load per project .nvimrc files, asks for confirmation.
	vim.o.exrc = true

	local vscode = require("config.vscode")

	require("config.pack").setup()

	if not vscode.enabled() then
		require("config.syntax").setup()
		require("config.lsp").setup()
		require("config.look").setup()
	end

	require("config.sane_defaults").setup()
	require("config.keybindings").setup()
	require("config.misc").setup()
end

return M
