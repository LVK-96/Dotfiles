#!/usr/bin/env lua

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
