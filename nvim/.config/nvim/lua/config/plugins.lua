local plugins = {}

-- Keep this table close to :help vim.pack.Spec; plugin setup lives in config.plugin_config.
local function gh(repo)
	return "https://github.com/" .. repo
end

local function add(spec)
	plugins[#plugins + 1] = spec
end

local regular_nvim = not vim.g.vscode
if regular_nvim then
	-- Themes and UI
	add(gh("ishan9299/nvim-solarized-lua"))
	add(gh("nvim-mini/mini.statusline"))
	add(gh("nvim-tree/nvim-web-devicons"))

	-- Navigation
	add(gh("A7Lavinraj/fyler.nvim"))
	add(gh("ibhagwan/fzf-lua"))
	add(gh("elanmed/fzf-lua-frecency.nvim"))
	add(gh("christoomey/vim-tmux-navigator"))
	add(gh("folke/which-key.nvim"))
	add(gh("folke/snacks.nvim"))

	-- Git
	add(gh("tpope/vim-fugitive"))
	add(gh("lewis6991/gitsigns.nvim"))
	add(gh("esmuellert/codediff.nvim"))

	-- Languages and syntax
	add(gh("nvim-treesitter/nvim-treesitter"))
	add(gh("mrcjkb/rustaceanvim"))
	add(gh("scalameta/nvim-metals"))

	-- AI
	add(gh("zbirenbaum/copilot.lua"))
	add(gh("folke/sidekick.nvim"))
end

add({
	src = gh("kylechui/nvim-surround"),
	version = vim.version.range("*"),
})
add(gh("andymass/vim-matchup"))
add(gh("nvim-lua/plenary.nvim"))

return plugins
