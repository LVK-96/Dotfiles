local function strip_whitespace_on_buffer_write()
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        pattern = { "*" },
        callback = function()
            local save_cursor = vim.fn.getpos(".")
            pcall(function() vim.cmd [[%s/\s\+$//e]] end)
            vim.fn.setpos(".", save_cursor)
        end,
    })
end

local function highlight_yank()
    vim.api.nvim_create_autocmd("TextYankPost", {
        desc = "Highlight when yanking (copying) text",
        group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
        callback = function()
            vim.highlight.on_yank()
        end,
    })
end


function misc()
    highlight_yank()
    if not vim.g.vscode then
        strip_whitespace_on_buffer_write()
    end
end
