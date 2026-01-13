function statusline()
    -- 1. GIT BRANCH
    local function current_git_branch()
        local branch = vim.b.gitsigns_head
        if branch then return " " .. branch .. " " end
        if vim.fn.exists("*fugitive#head") == 1 then
            local fug = vim.fn["fugitive#head"]()
            if fug and fug ~= "" then return " " .. fug .. " " end
        end
        return ""
    end

    -- 2. FILE STATE ([+] / [RO])
    local function file_state()
        local s = ""
        if vim.bo.readonly then s = s .. "[RO] " end
        if vim.bo.modified then s = s .. "[+] " end
        return s
    end

    -- 3. LSP DIAGNOSTICS
    local function lsp_status()
        -- Safety check: ensure vim.diagnostic exists
        if not vim.diagnostic then return "" end
        local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        local s = ""
        if errors > 0 then s = s .. "E:" .. errors .. " " end
        if warnings > 0 then s = s .. "W:" .. warnings .. " " end
        return s
    end

    -- 4. ACTIVE LSP SERVER
    local function active_lsp()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then return "" end

        local names = {}
        for _, client in pairs(clients) do
            -- Filter out noisy clients like Copilot or Null-ls if you want
            if client.name ~= "copilot" then
                table.insert(names, client.name)
            end
        end
        if #names == 0 then return "" end
        return "[" .. table.concat(names, ", ") .. "] "
    end

    -- 5. SEARCH COUNT
    local function search_count()
        if vim.v.hlsearch == 0 then return "" end

        -- Use pcall to prevent errors during complex searches
        local ok, res = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 500 })
        if not ok or res.total == 0 then return "" end

        if res.incomplete == 1 then
            return " [?/" .. res.total .. "] "
        end
        return " [" .. res.current .. "/" .. res.total .. "] "
    end

    -- ASSEMBLE
    return table.concat({
        current_git_branch(),   -- Git
        active_lsp(),           -- LSP Server
        lsp_status(),           -- E:1 W:0
        "%=",                   -- Align Right
        search_count(),         -- [1/5] (Only shows when searching)
        " %y ",                 -- FileType
        " %l:%c ",              -- Line:Col
    })
end

-- Handle mouse clicks on tabs
function MyTabClick(minwid, clicks, btn, modifiers)
    local buffers = vim.tbl_filter(function(b) return vim.bo[b].buflisted end, vim.api.nvim_list_bufs())
    if buffers[minwid] then vim.api.nvim_set_current_buf(buffers[minwid]) end
end

function my_tabline()
    local s = ""
    -- Get list of all listed buffers
    local buffers = vim.tbl_filter(function(b)
        return vim.bo[b].buflisted and vim.api.nvim_buf_is_valid(b)
    end, vim.api.nvim_list_bufs())
    for index, buf_id in ipairs(buffers) do
        local is_selected = (buf_id == vim.api.nvim_get_current_buf())
        local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf_id), ":t")
        if name == "" then name = "[No Name]" end
        -- Add modification indicator
        if vim.bo[buf_id].modified then
            name = name .. " +"
        elseif vim.bo[buf_id].readonly then
            name = name .. " [RO]"
        end
        -- Color logic: Select vs Inactive
        if is_selected then
            s = s .. "%#TabLineSel#" -- Active Buffer Color
        else
            s = s .. "%#TabLine#"    -- Inactive Buffer Color
        end
        -- Make the tab clickable with mouse
        s = s .. "%" .. index .. "@v:lua.MyTabClick@"

        -- THE FORMATTING: " 1 name "
        -- This adds the spacing and numbers you missed
        s = s .. " " .. index .. " " .. name .. " "
        -- Reset highlight
        s = s .. "%*"
    end
    -- Fill the rest of the bar with the background color
    s = s .. "%#TabLineFill#%T"
    return s
end


-- Apply the settings
local function tabline()
    vim.o.showtabline = 2 -- Always show the tabline
    vim.o.tabline = "%!v:lua.my_tabline()"
end

function look()
    vim.opt.termguicolors = true
    vim.opt.pumheight = 10
    vim.opt.completeopt = { "menu", "menuone", "noselect" }

    -- Highlight comments as italic
    vim.api.nvim_set_hl(0, "Comment", { italic = true, force = true })

    -- Statusline and tabline
    vim.opt.statusline = "%!v:lua.statusline()"
    tabline()
end
