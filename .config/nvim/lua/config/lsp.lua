function lsp()
    require'lspconfig'.pyright.setup{}

    require'lspconfig'.clangd.setup {
        cmd = { "chess-clangd" },
        autostart = false
    }

    require'lspconfig'.bashls.setup{}

    require('lspconfig').verible.setup{
        cmd = {'verible-verilog-ls', '--rules_config_search'},
        autostart = false
    }
end
