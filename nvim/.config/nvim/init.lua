#!/usr/bin/env lua

-- Enable Lua module caching for faster startup
vim.loader.enable()

-- Disable unused built-in plugins (must be before plugin loading)
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

-- Disable unused providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

require("config.lazy")
require("config.sane_defaults")
require("config.syntax")
require("config.lsp")
require("config.look")
require("config.keybindings")
require("config.misc")

function main()
    if not vim.g.vscode then
        syntax()
        lsp()
        look()
    end
    sane_defaults()
    keybindings()
    misc()
end

main()
