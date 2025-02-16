#!/usr/bin/env lua

require("config.lazy")
require("config.sane_defaults")
require("config.syntax")
require("config.lsp")
require("config.look")
require("config.keybindings")
require("config.misc")

function main()
    sane_defaults()
    syntax()
    lsp()
    look()
    keybindings()
    misc()
end

main()
