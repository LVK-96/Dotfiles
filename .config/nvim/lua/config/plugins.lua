return {
    -- Theme
    {
        "lifepillar/vim-solarized8",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("colorscheme solarized8")
        end,
    },

    -- Enhancements
    { "ap/vim-buftabline" },
    { "yggdroot/indentline" },
    { "ntpeters/vim-better-whitespace" },
    { "airblade/vim-gitgutter" },
    { "machakann/vim-highlightedyank" },
    { "tpope/vim-fugitive" },
    { "tpope/vim-surround" },
    { "andymass/vim-matchup" },
    { "tpope/vim-commentary" },
    { "breuckelen/vim-resize" },
    { "junegunn/vim-easy-align" },

    -- Navigation
    { "tpope/vim-vinegar" },
    { "junegunn/fzf" },
    { "junegunn/fzf.vim" },
    { "airblade/vim-rooter" },
    { "christoomey/vim-tmux-navigator" },

    -- LSP
    { "neovim/nvim-lspconfig" },

    -- Copilot
    { "github/copilot.vim" },

    -- Autocomplete
    {
        'saghen/blink.cmp',
        -- optional: provides snippets for the snippet source
        dependencies = 'rafamadriz/friendly-snippets',

        -- use a release tag to download pre-built binaries
        version = '*',
        -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
        -- build = 'cargo build --release',
        -- If you use nix, you can build from source using latest nightly rust with:
        -- build = 'nix run .#build-plugin',

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- 'default' for mappings similar to built-in completion
            -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
            -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
            -- See the full "keymap" documentation for information on defining your own keymap.
            keymap = { preset = 'default' },

            appearance = {
                -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                -- Useful for when your theme doesn't support blink.cmp
                -- Will be removed in a future release
                use_nvim_cmp_as_default = true,
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'mono'
            },

            -- No icons
            completion = {
                menu = {
                    draw = {
                        columns = { { "label", "label_description", gap = 1 }, { "kind" } },
                    }
                }
            },

            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
              default = { 'lsp', 'path', 'snippets', 'buffer' },
            },
        },
        opts_extend = { "sources.default" }
    }
}
