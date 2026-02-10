function statusline()
	-- 1. GIT BRANCH
	local function current_git_branch()
		local ok, res = pcall(function()
			local branch = vim.b.gitsigns_head
			if branch then
				return " " .. branch .. " "
			end
			if vim.fn.exists("*fugitive#head") == 1 then
				local fug = vim.fn["fugitive#head"]()
				if fug and fug ~= "" then
					return " " .. fug .. " "
				end
			end
		end)
		if ok and res then
			return res
		end
		return ""
	end

	-- 2. FILE STATE ([+] / [RO])
	local function file_state()
		local s = ""
		if vim.bo.readonly then
			s = s .. "[RO] "
		end
		if vim.bo.modified then
			s = s .. "[+] "
		end
		return s
	end

	-- 3. LSP DIAGNOSTICS
	local function lsp_status()
		-- Safety check: ensure vim.diagnostic exists
		if not vim.diagnostic then
			return ""
		end
		local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
		local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
		local s = ""
		if errors > 0 then
			s = s .. "E:" .. errors .. " "
		end
		if warnings > 0 then
			s = s .. "W:" .. warnings .. " "
		end
		return s
	end

	-- 4. ACTIVE LSP SERVER
	local function active_lsp()
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		if #clients == 0 then
			return ""
		end

		local names = {}
		for _, client in pairs(clients) do
			-- Filter out noisy clients like Copilot or Null-ls if you want
			if client.name ~= "copilot" then
				table.insert(names, client.name)
			end
		end
		if #names == 0 then
			return ""
		end
		return "[" .. table.concat(names, ", ") .. "] "
	end

	-- 5. SEARCH COUNT
	local function search_count()
		if vim.v.hlsearch == 0 then
			return ""
		end

		-- Use pcall to prevent errors during complex searches
		local ok, res = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 500 })
		if not ok or not res or not res.total or res.total == 0 then
			return ""
		end

		if res.incomplete == 1 then
			return " [?/" .. res.total .. "] "
		end
		return " [" .. res.current .. "/" .. res.total .. "] "
	end

	-- ASSEMBLE
	return table.concat({
		current_git_branch(), -- Git
		active_lsp(), -- LSP Server
		lsp_status(), -- E:1 W:0
		"%=", -- Align Right
		search_count(), -- [1/5] (Only shows when searching)
		" %y ", -- FileType
		" %l:%c ", -- Line:Col
	})
end

-- Handle mouse clicks on tabs
function MyTabClick(minwid, clicks, btn, modifiers)
	local buffers = vim.tbl_filter(function(b)
		return vim.bo[b].buflisted
	end, vim.api.nvim_list_bufs())
	if buffers[minwid] then
		vim.api.nvim_set_current_buf(buffers[minwid])
	end
end

-- Current tabline page (0-indexed)
_G.tabline_page = _G.tabline_page or 0
_G.tabline_manual_page = _G.tabline_manual_page or false -- Track if user manually switched pages
local BUFFERS_PER_PAGE = 10

-- Navigate to next/previous tabline page (circular)
function _G.tabline_next_page()
	local buffers = vim.tbl_filter(function(b)
		return vim.bo[b].buflisted and vim.api.nvim_buf_is_valid(b)
	end, vim.api.nvim_list_bufs())
	local max_page = math.max(0, math.ceil(#buffers / BUFFERS_PER_PAGE) - 1)
	if _G.tabline_page < max_page then
		_G.tabline_page = _G.tabline_page + 1
	else
		_G.tabline_page = 0 -- Wrap to first page
	end
	_G.tabline_manual_page = true
	vim.cmd("redrawtabline")
end

function _G.tabline_prev_page()
	local buffers = vim.tbl_filter(function(b)
		return vim.bo[b].buflisted and vim.api.nvim_buf_is_valid(b)
	end, vim.api.nvim_list_bufs())
	local max_page = math.max(0, math.ceil(#buffers / BUFFERS_PER_PAGE) - 1)
	if _G.tabline_page > 0 then
		_G.tabline_page = _G.tabline_page - 1
	else
		_G.tabline_page = max_page -- Wrap to last page
	end
	_G.tabline_manual_page = true
	vim.cmd("redrawtabline")
end

function my_tabline()
	local s = ""
	-- Get list of all listed buffers
	local buffers = vim.tbl_filter(function(b)
		return vim.bo[b].buflisted and vim.api.nvim_buf_is_valid(b)
	end, vim.api.nvim_list_bufs())

	-- Only auto-follow if user didn't manually switch pages
	if not _G.tabline_manual_page then
		local current_buf = vim.api.nvim_get_current_buf()
		for i, buf_id in ipairs(buffers) do
			if buf_id == current_buf then
				_G.tabline_page = math.floor((i - 1) / BUFFERS_PER_PAGE)
				break
			end
		end
	end

	-- Prepare buffer names (handle duplicates)
	local buf_names = {}
	local name_counts = {}

	-- First pass: count names
	for _, buf_id in ipairs(buffers) do
		local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf_id), ":t")
		if name == "" then
			name = "[No Name]"
		end
		name_counts[name] = (name_counts[name] or 0) + 1
	end

	-- Second pass: disambiguate
	for _, buf_id in ipairs(buffers) do
		local path = vim.api.nvim_buf_get_name(buf_id)
		local name = vim.fn.fnamemodify(path, ":t")
		if name == "" then
			name = "[No Name]"
		end

		if name_counts[name] > 1 and name ~= "[No Name]" then
			local parent = vim.fn.fnamemodify(path, ":h:t")
			if #parent > 15 then
				parent = string.sub(parent, 1, 5) .. ".." .. string.sub(parent, -5)
			end
			name = parent .. "/" .. name
		end
		buf_names[buf_id] = name
	end

	-- Calculate pagination
	local total_pages = math.max(1, math.ceil(#buffers / BUFFERS_PER_PAGE))
	_G.tabline_page = math.min(_G.tabline_page, total_pages - 1)
	local start_idx = _G.tabline_page * BUFFERS_PER_PAGE + 1
	local end_idx = math.min(start_idx + BUFFERS_PER_PAGE - 1, #buffers)

	-- Show page indicator if more than one page
	if total_pages > 1 then
		s = s .. "%#TabLineFill# [" .. (_G.tabline_page + 1) .. "/" .. total_pages .. "] "
	end

	-- Only show buffers for current page
	for i = start_idx, end_idx do
		local buf_id = buffers[i]
		local display_index = i - start_idx + 1 -- 1-10 for hotkeys
		local is_selected = (buf_id == vim.api.nvim_get_current_buf())
		local name = buf_names[buf_id]
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
			s = s .. "%#TabLine#" -- Inactive Buffer Color
		end
		-- Make the tab clickable with mouse (use actual buffer index for click)
		s = s .. "%" .. i .. "@v:lua.MyTabClick@"

		-- THE FORMATTING: " 1 name " (display 1-10 for hotkey reference)
		s = s .. " " .. display_index .. " " .. name .. " "
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
	vim.opt.laststatus = 2
	tabline()
end
