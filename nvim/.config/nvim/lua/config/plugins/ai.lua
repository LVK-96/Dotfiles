local M = {}

local util = require("config.plugins.util")

local function setup_copilot()
	util.safe("copilot.lua", function()
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
	end)

	vim.keymap.set("i", "<C-l>", function()
		local suggestion = require("copilot.suggestion")
		if suggestion.is_visible() then
			suggestion.accept()
			return ""
		end
	end)
end

local function setup_sidekick()
	util.safe("snacks.nvim", function()
		require("snacks").setup({
			input = { enabled = true },
			picker = { enabled = true },
		})
	end)

	util.safe("sidekick.nvim", function()
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
	end)

	vim.keymap.set("n", "<leader>oo", function()
		require("sidekick.cli").toggle()
	end, { desc = "AI: Toggle Chat" })
	vim.keymap.set("x", "<leader>oa", function()
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
	end, { desc = "Send Visual Selection" })
	vim.keymap.set("n", "<leader>oa", function()
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
	end, { desc = "AI: Ask (Word)" })
	vim.keymap.set("n", "<leader>af", function()
		require("snacks").input({ prompt = "file: " }, function(input)
			if not input then
				return
			end
			require("sidekick.cli").send({ msg = input .. "\n\nFile Context:\n{file}" })
		end)
	end, { desc = "AI: Send Whole File" })
end

function M.setup()
	setup_copilot()
	setup_sidekick()
end

return M
