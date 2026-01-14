function keybindings()
    local opts = { silent = true }

    -- 1. Insert Mode -> Normal Mode
    -- (Standard "Exit Insert")
    vim.keymap.set("i", "<C-q>", "<Esc>", { desc = "Exit Insert Mode" })

    -- 2. Visual/Select Mode -> Normal Mode
    -- (Cancels selection)
    vim.keymap.set("v", "<C-q>", "<Esc>", { desc = "Exit Visual Mode" })

    -- 3. Command Mode -> Normal Mode
    -- (Closes the : command line if you change your mind)
    vim.keymap.set("c", "<C-q>", "<C-c>", { desc = "Exit Command Mode" })

    -- 4. Terminal Mode -> Normal Mode
    -- (This goes inside an Autocmd to ensure it attaches to every terminal)
    vim.api.nvim_create_autocmd("TermOpen", {
        desc = "Universal Exit Binding for Terminals",
        callback = function()
            -- The crucial part: Maps Ctrl+g to the Exit Sequence
            -- nowait=true is SAFE here because Ctrl+g is not a prefix key
            local opts = { buffer = 0, nowait = true }

            vim.keymap.set("t", "<C-q>", [[<C-\><C-n>]], opts)

            -- KEEP your navigation chords here too!
            vim.keymap.set("t", "<C-a>h", [[<C-\><C-n><cmd>TmuxNavigateLeft<cr>]], opts)
            vim.keymap.set("t", "<C-a>j", [[<C-\><C-n><cmd>TmuxNavigateDown<cr>]], opts)
            vim.keymap.set("t", "<C-a>k", [[<C-\><C-n><cmd>TmuxNavigateUp<cr>]], opts)
            vim.keymap.set("t", "<C-a>l", [[<C-\><C-n><cmd>TmuxNavigateRight<cr>]], opts)
        end,
    })

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

    -- Tabline navigation (respects pagination)
    local BUFFERS_PER_PAGE = 10
    for i = 1, 9 do
        vim.keymap.set("n", "<leader>" .. i, function()
            if vim.g.vscode then
                require('vscode').call("workbench.action.openEditorAtIndex" .. i)
            else
                local buffers = vim.tbl_filter(function(b) return vim.bo[b].buflisted end, vim.api.nvim_list_bufs())
                local page = _G.tabline_page or 0
                local global_index = page * BUFFERS_PER_PAGE + i
                if buffers[global_index] then vim.api.nvim_set_current_buf(buffers[global_index]) end
            end
        end, { desc = "Go to Tab " .. i })
    end

    vim.keymap.set("n", "<leader>0", function()
        if vim.g.vscode then
            require('vscode').call("workbench.action.lastEditorInGroup")
        else
            local buffers = vim.tbl_filter(function(b) return vim.bo[b].buflisted end, vim.api.nvim_list_bufs())
            local page = _G.tabline_page or 0
            local page_end = math.min((page + 1) * BUFFERS_PER_PAGE, #buffers)
            if buffers[page_end] then vim.api.nvim_set_current_buf(buffers[page_end]) end
        end
    end, { desc = "Last Buffer on Page" })

    -- Tabline page navigation (Tab/S-Tab in normal mode)
    vim.keymap.set("n", "<Tab>", function()
        _G.tabline_next_page()
    end, { desc = "Next tabline page" })

    vim.keymap.set("n", "<S-Tab>", function()
        _G.tabline_prev_page()
    end, { desc = "Previous tabline page" })

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

        -- Force Ctrl+[ to behave exactly like Ctrl-\ Ctrl-n
        vim.keymap.set("t", "<C-[>", [[<C-\><C-n>]], { desc = "Exit Terminal Mode", buffer = 0 })
    end
end
