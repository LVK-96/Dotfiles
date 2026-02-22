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

-- Minimum characters reserved per tab: " N name " (hotkey + spaces + padding)
local MIN_CHARS_PER_TAB = 4
-- Characters for page indicator: " [N/M] " (page counter with brackets and spaces)
local PAGE_INDICATOR_CHARS = 8

-- Calculate the display width of a string (handles Unicode)
local function str_width(str)
	return vim.fn.strdisplaywidth(str)
end

-- Calculate how many tabs can fit in the available width
local function calculate_tabs_per_page(buffer_data, available_width, show_page_indicator)
	local indicator_width = show_page_indicator and PAGE_INDICATOR_CHARS or 0
	local remaining_width = available_width - indicator_width

	local count = 0
	local total_width = 0

	for _, data in ipairs(buffer_data) do
		local tab_width = math.max(MIN_CHARS_PER_TAB, str_width(data.display_name) + 3) -- +3 for " N "
		if total_width + tab_width <= remaining_width then
			total_width = total_width + tab_width
			count = count + 1
		else
			break
		end
	end

	return math.max(1, count)
end

-- Helper function to get current tabs per page calculation
function _G.get_tabs_per_page()
	local buffers = vim.tbl_filter(function(b)
		return vim.bo[b].buflisted and vim.api.nvim_buf_is_valid(b)
	end, vim.api.nvim_list_bufs())
	local buf_data = prepare_buffer_data(buffers)
	local available_width = vim.o.columns
	local show_indicator = #buffers > 1
	return calculate_tabs_per_page(buf_data, available_width, show_indicator)
end

-- Helper function to jump to Nth tab on current page (1-indexed)
function _G.jump_to_tab_on_page(page_relative_index)
	local buffers = vim.tbl_filter(function(b)
		return vim.bo[b].buflisted and vim.api.nvim_buf_is_valid(b)
	end, vim.api.nvim_list_bufs())

	local tabs_per_page = _G.get_tabs_per_page()
	local current_page = _G.tabline_page or 0
	-- Calculate global buffer index from page-relative index
	local global_index = current_page * tabs_per_page + page_relative_index

	if buffers[global_index] then
		vim.api.nvim_set_current_buf(buffers[global_index])
	end
end

-- Helper function to jump to last tab on current page
function _G.jump_to_last_tab_on_page()
	local buffers = vim.tbl_filter(function(b)
		return vim.bo[b].buflisted and vim.api.nvim_buf_is_valid(b)
	end, vim.api.nvim_list_bufs())

	local tabs_per_page = _G.get_tabs_per_page()
	local current_page = _G.tabline_page or 0
	-- Calculate the last index on current page
	local page_start = current_page * tabs_per_page + 1
	local page_end = math.min(page_start + tabs_per_page - 1, #buffers)

	if buffers[page_end] then
		vim.api.nvim_set_current_buf(buffers[page_end])
	end
end

-- Navigate to next/previous tabline page (circular)
function _G.tabline_next_page()
	local buffers = vim.tbl_filter(function(b)
		return vim.bo[b].buflisted and vim.api.nvim_buf_is_valid(b)
	end, vim.api.nvim_list_bufs())
	local buf_data = prepare_buffer_data(buffers)
	local available_width = vim.o.columns
	local show_indicator = #buffers > 1
	local tabs_per_page = calculate_tabs_per_page(buf_data, available_width, show_indicator)
	local max_page = math.max(0, math.ceil(#buffers / tabs_per_page) - 1)

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
	local buf_data = prepare_buffer_data(buffers)
	local available_width = vim.o.columns
	local show_indicator = #buffers > 1
	local tabs_per_page = calculate_tabs_per_page(buf_data, available_width, show_indicator)
	local max_page = math.max(0, math.ceil(#buffers / tabs_per_page) - 1)

	if _G.tabline_page > 0 then
		_G.tabline_page = _G.tabline_page - 1
	else
		_G.tabline_page = max_page -- Wrap to last page
	end
	_G.tabline_manual_page = true
	vim.cmd("redrawtabline")
end

-- Prepare buffer display data
function prepare_buffer_data(buffers)
	local buf_data = {}
	local name_counts = {}

	-- First pass: count names
	for _, buf_id in ipairs(buffers) do
		local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf_id), ":t")
		if name == "" then
			name = "[No Name]"
		end
		name_counts[name] = (name_counts[name] or 0) + 1
	end

	-- Second pass: build display data with disambiguated names
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

		-- Add modification indicator
		if vim.bo[buf_id].modified then
			name = name .. " +"
		elseif vim.bo[buf_id].readonly then
			name = name .. " [RO]"
		end

		table.insert(buf_data, {
			buf_id = buf_id,
			display_name = name,
			is_selected = (buf_id == vim.api.nvim_get_current_buf()),
		})
	end

	return buf_data
end

function my_tabline()
	local s = ""
	local available_width = vim.o.columns

	-- Get list of all listed buffers
	local buffers = vim.tbl_filter(function(b)
		return vim.bo[b].buflisted and vim.api.nvim_buf_is_valid(b)
	end, vim.api.nvim_list_bufs())

	-- Prepare buffer display data
	local buf_data = prepare_buffer_data(buffers)
	local show_indicator = #buffers > 1

	-- Calculate tabs per page based on available width
	local tabs_per_page = calculate_tabs_per_page(buf_data, available_width, show_indicator)

	-- Only auto-follow if user didn't manually switch pages
	if not _G.tabline_manual_page then
		local current_buf = vim.api.nvim_get_current_buf()
		for i, data in ipairs(buf_data) do
			if data.buf_id == current_buf then
				_G.tabline_page = math.floor((i - 1) / tabs_per_page)
				break
			end
		end
	end

	-- Calculate pagination
	local total_pages = math.max(1, math.ceil(#buffers / tabs_per_page))
	_G.tabline_page = math.min(_G.tabline_page, total_pages - 1)
	local start_idx = _G.tabline_page * tabs_per_page + 1
	local end_idx = math.min(start_idx + tabs_per_page - 1, #buffers)

	-- Show page indicator if more than one page
	if show_indicator then
		s = s .. "%#TabLineFill# [" .. (_G.tabline_page + 1) .. "/" .. total_pages .. "] "
	end

	-- Only show buffers that fit on current page
	for i = start_idx, end_idx do
		local data = buf_data[i]
		local display_index = i - start_idx + 1

		-- Color logic: Select vs Inactive
		if data.is_selected then
			s = s .. "%#TabLineSel#"
		else
			s = s .. "%#TabLine#"
		end

		-- Make the tab clickable with mouse
		s = s .. "%" .. i .. "@v:lua.MyTabClick@"

		-- THE FORMATTING: " N name "
		s = s .. " " .. display_index .. " " .. data.display_name .. " "
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
	vim.opt.fillchars = { eob = " " } -- hide "~" on empty lines

	-- Highlight comments as italic
	vim.api.nvim_set_hl(0, "Comment", { italic = true, force = true })

	-- Statusline and tabline
	vim.opt.laststatus = 2
	tabline()
end
