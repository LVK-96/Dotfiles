local plugins = {}

-- Keep this table close to :help vim.pack.Spec; plugin setup lives in config.plugin_config.
local function gh(repo)
	return "https://github.com/" .. repo
end

local function add(spec)
	plugins[#plugins + 1] = spec
end

local regular_nvim = not require("config.vscode").enabled()
if regular_nvim then
	-- Themes and UI
	add(gh("dchinmay2/alabaster.nvim"))
	add(gh("nvim-tree/nvim-web-devicons"))
	add(gh("nvim-mini/mini.statusline"))

	-- Navigation
	add(gh("A7Lavinraj/fyler.nvim"))
	add(gh("ibhagwan/fzf-lua"))
	add(gh("elanmed/fzf-lua-frecency.nvim"))
	add(gh("christoomey/vim-tmux-navigator"))
	add(gh("MagicDuck/grug-far.nvim"))
	add(gh("folke/which-key.nvim"))
	add(gh("folke/snacks.nvim"))
	add(gh("folke/todo-comments.nvim"))
	add(gh("folke/trouble.nvim"))
	add(gh("folke/flash.nvim"))
	add(gh("saghen/blink.lib"))
	add(gh("saghen/blink.cmp"))

	-- Git
	add(gh("neogitorg/neogit"))
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

add(gh("nvim-mini/mini.ai"))
add(gh("nvim-mini/mini.align"))
add(gh("nvim-mini/mini.comment"))
add(gh("nvim-mini/mini.move"))
add(gh("nvim-mini/mini.operators"))
add(gh("nvim-mini/mini.pairs"))
add(gh("nvim-mini/mini.snippets"))
add(gh("nvim-mini/mini.splitjoin"))
add(gh("andymass/vim-matchup"))
add(gh("nvim-lua/plenary.nvim"))
add(gh("NMAC427/guess-indent.nvim"))

return plugins
