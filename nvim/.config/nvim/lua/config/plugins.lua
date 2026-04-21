local plugins = {}

-- Keep this table close to :help vim.pack.Spec; plugin setup lives in config.plugin_config.
local function gh(repo)
	return "https://github.com/" .. repo
end

local function add(spec)
	plugins[#plugins + 1] = spec
end

local regular_nvim = not vim.g.vscode
local ai_plugin = os.getenv("NVIM_AI")

if regular_nvim then
	add(gh("ishan9299/nvim-solarized-lua"))
end

add(gh("nvim-mini/mini.statusline"))
add(gh("nvim-tree/nvim-web-devicons"))

if regular_nvim then
	add(gh("stevearc/oil.nvim"))
	add(gh("refractalize/oil-git-status.nvim"))
end

add(gh("nvim-tree/nvim-tree.lua"))
add(gh("ibhagwan/fzf-lua"))

if regular_nvim then
	add(gh("christoomey/vim-tmux-navigator"))
	add(gh("lewis6991/gitsigns.nvim"))
	add(gh("tpope/vim-fugitive"))
end

add(gh("sindrets/diffview.nvim"))

if regular_nvim then
	add(gh("nvim-treesitter/nvim-treesitter"))
end

add({
	src = gh("kylechui/nvim-surround"),
	version = vim.version.range("*"),
})
add(gh("andymass/vim-matchup"))
add(gh("folke/which-key.nvim"))

if regular_nvim then
	add(gh("mrcjkb/rustaceanvim"))
end

add(gh("nvim-lua/plenary.nvim"))
add(gh("scalameta/nvim-metals"))

if regular_nvim then
	add(gh("zbirenbaum/copilot.lua"))
end

add(gh("folke/snacks.nvim"))

add(gh("folke/sidekick.nvim"))

return plugins
