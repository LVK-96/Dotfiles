local function rooter_patterns()
    vim.g.rooter_patterns = {'Pipfile', 'package.json', '.git', '.git/', '_darcs/', '.hg/', '.bzr/', '.svn/'}
end

local function strip_whitespace_on_buffer_write()
    vim.api.nvim_create_autocmd(
        {"BufWritePre"},
        {
        pattern={"*"},
        command= ":StripWhitespace"
        }
    )
end

function misc()
    rooter_patterns()
    strip_whitespace_on_buffer_write()
end
