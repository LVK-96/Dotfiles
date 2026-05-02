local M = {}

local lazy = require("config.plugins.lazy")

local function configure_copilot()
	require("copilot").setup({
		suggestion = {
			enabled = true,
			auto_trigger = true,
			keymap = {
				accept = false,
			},
		},
		panel = { enabled = false },
	})
end

local function setup_copilot()
	lazy.on_event("InsertEnter", "copilot.lua", configure_copilot)

	lazy.map("i", "<C-l>", "copilot.lua", configure_copilot, function()
		local suggestion = require("copilot.suggestion")
		if suggestion.is_visible() then
			suggestion.accept()
			return ""
		end
	end)
end

local function configure_sidekick()
	require("sidekick").setup({
		nes = { enabled = false },
		cli = {
			enabled = true,
			mux = {
				backend = "tmux",
				enabled = "true",
				create = "split",
				split = {
					axis = "vertical",
					size = 0.3,
				},
			},
		},
	})
end

local function send_visual_selection()
	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")
	local start_row, start_col = start_pos[2] - 1, start_pos[3] - 1
	local end_row, end_col = end_pos[2] - 1, end_pos[3]

	if end_row < start_row or (end_row == start_row and end_col < start_col) then
		start_row, end_row = end_row, start_row
		start_col, end_col = end_col, start_col
	end

	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		return
	end

	local rel = vim.fn.fnamemodify(file, ":.")
	local start_line = start_row + 1
	local end_line = end_row + 1
	local ref = string.format("@%s:%d-%d", rel, start_line, end_line)
	require("sidekick.cli").send({ msg = ref })
end

local function ask_about_word()
	local word = vim.fn.expand("<cword>")
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		return
	end
	local rel = vim.fn.fnamemodify(file, ":.")
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local ref = string.format("@%s:%d-%d", rel, line, line)
	require("snacks").input({ prompt = "'" .. word .. "': " }, function(input)
		if not input then
			return
		end
		require("sidekick.cli").send({ msg = input .. "\n\nContext: " .. ref })
	end)
end

local function send_whole_file()
	require("snacks").input({ prompt = "file: " }, function(input)
		if not input then
			return
		end
		require("sidekick.cli").send({ msg = input .. "\n\nFile Context:\n{file}" })
	end)
end

local function setup_sidekick()
	lazy.map("n", "<leader>oo", "sidekick.nvim", configure_sidekick, function()
		require("sidekick.cli").toggle()
	end, { desc = "AI: Toggle Chat" })
	lazy.map(
		"x",
		"<leader>oa",
		"sidekick.nvim",
		configure_sidekick,
		send_visual_selection,
		{ desc = "Send Visual Selection" }
	)
	lazy.map("n", "<leader>oa", "sidekick.nvim", configure_sidekick, ask_about_word, { desc = "AI: Ask (Word)" })
	lazy.map("n", "<leader>af", "sidekick.nvim", configure_sidekick, send_whole_file, { desc = "AI: Send Whole File" })
end

function M.setup()
	setup_copilot()
	setup_sidekick()
end

return M
