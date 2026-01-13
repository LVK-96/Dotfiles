function keybindings()
    local opts = { silent = true }

    -- Clear search highlighting
    vim.keymap.set("n", "<leader>l", function()
        -- 1. Clear search highlighting
        vim.cmd.nohlsearch()

        -- 2. Update diffs (if the current window is in diff mode)
        if vim.wo.diff then
            vim.cmd.diffupdate()
        end

        -- 3. Redraw the screen (Equivalent to <C-L>)
        vim.cmd("redraw!")
    end, { desc = "Clear highlights, update diffs & redraw" })

    -- Tabline navigation
    for i = 1, 9 do
        vim.keymap.set("n", "<leader>" .. i, function()
            if vim.g.vscode then
                -- Trigger the VS Code command "Open Editor at Index X"
                require('vscode').call("workbench.action.openEditorAtIndex" .. i)
            else
                local buffers = vim.tbl_filter(function(b) return vim.bo[b].buflisted end, vim.api.nvim_list_bufs())
                if buffers[i] then vim.api.nvim_set_current_buf(buffers[i]) end
            end
        end, { desc = "Go to Tab " .. i })
    end

    vim.keymap.set("n", "<leader>0", function()
        if vim.g.vscode then
            require('vscode').call("workbench.action.lastEditorInGroup")
        else
            local buffers = vim.tbl_filter(function(b) return vim.bo[b].buflisted end, vim.api.nvim_list_bufs())
            if #buffers > 0 then vim.api.nvim_set_current_buf(buffers[#buffers]) end
        end
    end, { desc = "Last Buffer" })

    vim.keymap.set("n", "<C-X>", function()
        if vim.g.vscode then
            require('vscode').call("workbench.action.closeActiveEditor")
        else
            vim.cmd("bdelete")
        end
    end, { desc = "Close buffer" })

    if not vim.g.vscode then
        -- Tab completion keymaps
        -- plugins.lua has the normal Tab since it needs to handle LSP + Copilot
        -- Shift+Tab to go up
        vim.keymap.set("i", "<S-Tab>", function()
            return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
        end, { expr = true })
        -- If menu is open, confirm selection. If not, just insert a newline.
        vim.keymap.set("i", "<CR>", function()
            return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
        end, { expr = true })
    end
end
