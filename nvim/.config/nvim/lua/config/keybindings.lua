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
	-- Leader + number: jump to tab on current page (1-9 = first 9 tabs, 0 = last tab on page)
	for i = 1, 9 do
		vim.keymap.set("n", "<leader>" .. i, function()
			if vim.g.vscode then
				require("vscode").call("workbench.action.openEditorAtIndex" .. i)
			else
				_G.jump_to_tab_on_page(i)
			end
		end, { desc = "Go to tab " .. i .. " on current page" })
	end

	vim.keymap.set("n", "<leader>0", function()
		if vim.g.vscode then
			require("vscode").call("workbench.action.lastEditorInGroup")
		else
			_G.jump_to_last_tab_on_page()
		end
	end, { desc = "Last tab on current page" })

	-- Tabline page navigation (Tab/S-Tab in normal mode)
	vim.keymap.set("n", "<Tab>", function()
		_G.tabline_next_page()
	end, { desc = "Next tabline page" })

	vim.keymap.set("n", "<S-Tab>", function()
		_G.tabline_prev_page()
	end, { desc = "Previous tabline page" })

	vim.keymap.set("n", "<C-X>", function()
		if vim.g.vscode then
			require("vscode").call("workbench.action.closeActiveEditor")
		else
			Snacks.bufdelete()
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

	-- FZF-Lua LSP Keybindings
	local function fzf(command)
		return function()
			require("fzf-lua")[command]()
		end
	end
	-- 1. References (Overrides default 'grr')
	-- Instead of the Quickfix list, this opens the FZF fuzzy finder.
	vim.keymap.set("n", "grr", fzf("lsp_references"), { desc = "FZF LSP References" })
	-- 2. Code Actions (Overrides default 'gra')
	-- Works in Normal mode and Visual mode (for range actions).
	vim.keymap.set({ "n", "v" }, "gra", fzf("lsp_code_actions"), { desc = "FZF LSP Code Actions" })
	-- 3. Definitions (Overrides default 'gd')
	-- Falls back to standard navigation if only one definition exists.
	vim.keymap.set("n", "gd", fzf("lsp_definitions"), { desc = "FZF LSP Definitions" })
	-- 4. Implementations (Overrides default 'gri' / 'gI')
	vim.keymap.set("n", "gI", fzf("lsp_implementations"), { desc = "FZF LSP Implementations" })
	vim.keymap.set("n", "gri", fzf("lsp_implementations"), { desc = "FZF LSP Implementations" })
	-- 5. Type Definitions (Overrides default 'gy')
	vim.keymap.set("n", "gy", fzf("lsp_typedefs"), { desc = "FZF LSP Type Definitions" })
	-- 6. Document Symbols (Bonus: usually mapped to <leader>ds)
	-- Lists functions, variables, and classes in the current file.
	vim.keymap.set("n", "<leader>ds", fzf("lsp_document_symbols"), { desc = "FZF Document Symbols" })
	vim.keymap.set("n", "<leader>dd", fzf("lsp_document_diagnostics"), { desc = "FZF Document Diagnostics" })
	vim.keymap.set("n", "<leader>DD", fzf("lsp_workspace_diagnostics"), { desc = "FZF Workspace Diagnostics" })
	-- LSP rename
	vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "LSP Rename" })

	-- Toggle inlay hints
	vim.keymap.set("n", "<leader>ih", function()
		local bufnr = vim.api.nvim_get_current_buf()
		local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
		vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
	end, { desc = "Toggle inlay hints" })
end
