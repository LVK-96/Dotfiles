function syntax()
    vim.api.nvim_create_autocmd(
        {"BufNewFile", "BufRead", "BufEnter"},
        {
        pattern={"Jenkinsfile"},
        command= "setf groovy"
        }
    )
    vim.api.nvim_create_autocmd(
        {"BufNewFile", "BufRead", "BufEnter"},
        {
        pattern={"*.sbt"},
        command= "set filetype=scala"
        }
    )
    vim.api.nvim_create_autocmd(
        {"BufNewFile", "BufRead", "BufEnter"},
        {
        pattern={"*.tsx", "*.jsx"},
        command= "set filetype=typescript.tsx"
        }
    )
    vim.api.nvim_create_autocmd(
        {"BufNewFile", "BufRead", "BufEnter"},
        {
        pattern={"*.n", "*.p"},
        command= "set filetype=cpp"
        }
    )
    vim.api.nvim_create_autocmd(
        {"BufNewFile", "BufRead", "BufEnter"},
        {
        pattern={"*.sva"},
        command= "set filetype=verilog"
        }
    )
    vim.api.nvim_create_autocmd(
        {"BufNewFile", "BufRead", "BufEnter"},
        {
        pattern={"*.bcf"},
        command= "set filetype=bcf"
        }
    )
    vim.api.nvim_create_autocmd(
        "FileType",
        {
        pattern={"*.bcf"},
        command= "setlocal commentstring=//\\ %s"
        }
    )
end
