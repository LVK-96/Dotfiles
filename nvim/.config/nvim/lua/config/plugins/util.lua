local M = {}

M.diff_highlights = {
	line_insert = "#e5e3b6",
	line_delete = "#f8d9c8",
	char_insert = "#d9dda3",
	char_delete = "#f0c0ad",
}

local function notify_error(message)
	vim.schedule(function()
		vim.notify(message, vim.log.levels.ERROR)
	end)
end

function M.safe(name, callback)
	local ok, err = pcall(callback)
	if not ok then
		notify_error(string.format("Plugin config failed for %s: %s", name, err))
	end
end

function M.setup_diff_highlights()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = true })
	local fallback_fg = normal and normal.fg or nil

	vim.api.nvim_set_hl(0, "DiffAdd", { fg = fallback_fg, bg = M.diff_highlights.line_insert })
	vim.api.nvim_set_hl(0, "DiffDelete", { fg = fallback_fg, bg = M.diff_highlights.line_delete })
end

function M.setup_neogit_highlights()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = true })
	local normal_fg = normal and normal.fg or nil
	local delete_fg = "#9f2d20"
	local add_fg = "#00856f"

	vim.api.nvim_set_hl(0, "NeogitDiffAdd", { fg = add_fg, bg = M.diff_highlights.line_insert })
	vim.api.nvim_set_hl(0, "NeogitDiffAddHighlight", { fg = add_fg, bg = M.diff_highlights.line_insert })
	vim.api.nvim_set_hl(0, "NeogitDiffAddCursor", { fg = add_fg, bg = M.diff_highlights.line_insert })
	vim.api.nvim_set_hl(0, "NeogitDiffDelete", { fg = delete_fg, bg = M.diff_highlights.line_delete })
	vim.api.nvim_set_hl(0, "NeogitDiffDeleteHighlight", { fg = delete_fg, bg = M.diff_highlights.line_delete })
	vim.api.nvim_set_hl(0, "NeogitDiffDeleteCursor", { fg = delete_fg, bg = M.diff_highlights.line_delete })
	vim.api.nvim_set_hl(0, "NeogitDiffAddInline", { fg = normal_fg, bg = M.diff_highlights.char_insert, bold = true })
	vim.api.nvim_set_hl(
		0,
		"NeogitDiffDeleteInline",
		{ fg = normal_fg, bg = M.diff_highlights.char_delete, bold = true }
	)
	vim.api.nvim_set_hl(0, "NeogitChangeDeleted", { fg = delete_fg, bold = true, italic = true })
	vim.api.nvim_set_hl(0, "NeogitChangeDstaged", { fg = delete_fg, bold = true, italic = true })
	vim.api.nvim_set_hl(0, "NeogitChangeDunstaged", { fg = delete_fg, bold = true, italic = true })
	vim.api.nvim_set_hl(0, "NeogitChangeDuntracked", { fg = delete_fg, bold = true, italic = true })
end

return M
