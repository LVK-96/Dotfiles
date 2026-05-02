local M = {}

local state = {
	page = 0,
	manual_page = false,
}

local MIN_CHARS_PER_TAB = 4
local MAX_TABS_PER_PAGE = 10
local PAGE_INDICATOR_CHARS = 8

local function is_normal_file_buffer(bufnr)
	return vim.api.nvim_buf_is_valid(bufnr)
		and vim.bo[bufnr].buflisted
		and vim.bo[bufnr].buftype == ""
		and vim.api.nvim_buf_get_name(bufnr) ~= ""
end

local function tabline_buffers()
	local buffers = vim.tbl_filter(is_normal_file_buffer, vim.api.nvim_list_bufs())
	table.sort(buffers)
	return buffers
end

local function escaped_tabline_text(text)
	return text:gsub("%%", "%%%%")
end

local function get_buffer_icon(bufnr)
	local path = vim.api.nvim_buf_get_name(bufnr)
	if path == "" then
		return "", ""
	end

	local ok, devicons = pcall(require, "nvim-web-devicons")
	if not ok then
		return "", ""
	end

	local filename = vim.fn.fnamemodify(path, ":t")
	local extension = vim.fn.fnamemodify(path, ":e")
	local icon = devicons.get_icon(filename, extension, { default = true })
	local _, icon_color = devicons.get_icon_color(filename, extension, { default = true })
	if not icon or icon == "" then
		return "", ""
	end

	return icon, icon_color or ""
end

local function get_icon_hl(icon_color, base_hl)
	if icon_color == "" then
		return nil
	end

	local ok, base = pcall(vim.api.nvim_get_hl, 0, { name = base_hl, link = false })
	if not ok then
		return nil
	end

	local visual_bg = base.reverse and base.fg or base.bg
	local visual_cterm_bg = base.reverse and base.ctermfg or base.ctermbg
	local group = "UserTabLineIcon" .. base_hl:gsub("%W", "") .. icon_color:gsub("%W", "")

	vim.api.nvim_set_hl(0, group, {
		fg = icon_color,
		bg = visual_bg,
		ctermbg = visual_cterm_bg,
		reverse = false,
		nocombine = true,
	})

	return group
end

local function prepare_buffer_data(buffers)
	local data = {}
	local name_counts = {}

	for _, bufnr in ipairs(buffers) do
		local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
		name_counts[name] = (name_counts[name] or 0) + 1
	end

	for _, bufnr in ipairs(buffers) do
		local path = vim.api.nvim_buf_get_name(bufnr)
		local name = vim.fn.fnamemodify(path, ":t")

		if name_counts[name] > 1 then
			local parent = vim.fn.fnamemodify(path, ":h:t")
			if #parent > 15 then
				parent = parent:sub(1, 5) .. ".." .. parent:sub(-5)
			end
			name = parent .. "/" .. name
		end

		local icon, icon_color = get_buffer_icon(bufnr)
		if icon ~= "" then
			name = name .. " " .. icon
		end

		if vim.bo[bufnr].modified then
			name = name .. " +"
		elseif vim.bo[bufnr].readonly then
			name = name .. " [RO]"
		end

		data[#data + 1] = {
			bufnr = bufnr,
			display_name = name,
			icon = icon,
			icon_color = icon_color,
			is_selected = bufnr == vim.api.nvim_get_current_buf(),
		}
	end

	return data
end

local function tab_width(buffer_data)
	return math.max(MIN_CHARS_PER_TAB, vim.fn.strdisplaywidth(buffer_data.display_name) + 3)
end

local function tabs_per_page(buffer_data, available_width, show_page_indicator)
	local indicator_width = show_page_indicator and PAGE_INDICATOR_CHARS or 0
	local remaining_width = available_width - indicator_width
	local count = 0
	local total_width = 0

	for _, data in ipairs(buffer_data) do
		local width = tab_width(data)
		if count >= MAX_TABS_PER_PAGE or total_width + width > remaining_width then
			break
		end

		total_width = total_width + width
		count = count + 1
	end

	return math.max(1, count)
end

local function current_tabs_per_page()
	local buffers = tabline_buffers()
	local buffer_data = prepare_buffer_data(buffers)
	local show_page_indicator = #buffers > 1
	return tabs_per_page(buffer_data, vim.o.columns, show_page_indicator)
end

local function total_pages(buffer_count, page_size)
	return math.max(1, math.ceil(buffer_count / page_size))
end

local function clamp_page(buffer_count, page_size)
	state.page = math.min(state.page, total_pages(buffer_count, page_size) - 1)
	state.page = math.max(state.page, 0)
end

local function follow_current_buffer(buffer_data, page_size)
	if state.manual_page then
		return
	end

	local current_bufnr = vim.api.nvim_get_current_buf()
	for index, data in ipairs(buffer_data) do
		if data.bufnr == current_bufnr then
			state.page = math.floor((index - 1) / page_size)
			return
		end
	end
end

local function render_icon(display_name, data, base_hl)
	if data.icon == "" then
		return escaped_tabline_text(display_name)
	end

	local icon_hl = get_icon_hl(data.icon_color, base_hl)
	local icon_start = icon_hl and display_name:find(data.icon, 1, true)
	if not icon_start then
		return escaped_tabline_text(display_name)
	end

	local before_icon = escaped_tabline_text(display_name:sub(1, icon_start - 1))
	local icon = escaped_tabline_text(data.icon)
	local after_icon = escaped_tabline_text(display_name:sub(icon_start + #data.icon))
	return before_icon .. "%#" .. icon_hl .. "#" .. icon .. "%#" .. base_hl .. "#" .. after_icon
end

function M.render()
	local buffers = tabline_buffers()
	local buffer_data = prepare_buffer_data(buffers)
	local show_page_indicator = #buffers > 1
	local page_size = tabs_per_page(buffer_data, vim.o.columns, show_page_indicator)
	local chunks = {}

	follow_current_buffer(buffer_data, page_size)
	clamp_page(#buffers, page_size)

	local pages = total_pages(#buffers, page_size)
	local start_index = state.page * page_size + 1
	local end_index = math.min(start_index + page_size - 1, #buffers)

	if show_page_indicator then
		chunks[#chunks + 1] = "%#TabLineFill# [" .. (state.page + 1) .. "/" .. pages .. "] "
	end

	for index = start_index, end_index do
		local data = buffer_data[index]
		local display_index = index - start_index + 1
		local base_hl = data.is_selected and "TabLineSel" or "TabLine"
		local display_name = render_icon(data.display_name, data, base_hl)

		chunks[#chunks + 1] = "%#" .. base_hl .. "#"
		chunks[#chunks + 1] = "%" .. index .. "@v:lua.ConfigNumberedTablineClick@"
		chunks[#chunks + 1] = " " .. display_index .. " " .. display_name .. " "
		chunks[#chunks + 1] = "%*"
	end

	chunks[#chunks + 1] = "%#TabLineFill#%T"
	return table.concat(chunks)
end

function M.click(index)
	local buffers = tabline_buffers()
	local bufnr = buffers[index]
	if bufnr then
		vim.api.nvim_set_current_buf(bufnr)
	end
end

function M.jump_to_page_index(page_relative_index)
	local buffers = tabline_buffers()
	local page_size = current_tabs_per_page()
	local index = state.page * page_size + page_relative_index
	local bufnr = buffers[index]

	if bufnr then
		vim.api.nvim_set_current_buf(bufnr)
	end
end

function M.next_page()
	local buffers = tabline_buffers()
	local page_size = current_tabs_per_page()
	local max_page = total_pages(#buffers, page_size) - 1

	if state.page < max_page then
		state.page = state.page + 1
	else
		state.page = 0
	end

	state.manual_page = true
	vim.cmd.redrawtabline()
end

function M.prev_page()
	local buffers = tabline_buffers()
	local page_size = current_tabs_per_page()
	local max_page = total_pages(#buffers, page_size) - 1

	if state.page > 0 then
		state.page = state.page - 1
	else
		state.page = max_page
	end

	state.manual_page = true
	vim.cmd.redrawtabline()
end

function M.setup()
	_G.ConfigNumberedTablineRender = M.render
	_G.ConfigNumberedTablineClick = M.click

	vim.o.showtabline = 2
	vim.o.tabline = "%!v:lua.ConfigNumberedTablineRender()"
end

return M
