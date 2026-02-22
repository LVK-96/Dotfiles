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
	-- LSP rename with prompt + autosave of files changed by the rename edit.
	vim.keymap.set("n", "<leader>cr", function()
		local current_name = vim.fn.expand("<cword>")
		vim.ui.input({ prompt = "Rename to: ", default = current_name }, function(new_name)
			if not new_name then
				return
			end
			new_name = vim.trim(new_name)
			if new_name == "" or new_name == current_name then
				return
			end

			local pre_existing = {}
			local pre_loaded = {}
			local pre_modified = {}
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				pre_existing[buf] = true
				pre_loaded[buf] = vim.api.nvim_buf_is_loaded(buf)
				if vim.bo[buf].modified then
					pre_modified[buf] = true
				end
			end

			local params = vim.lsp.util.make_position_params(0, "utf-16")
			params.newName = new_name

			vim.lsp.buf_request_all(0, "textDocument/rename", params, function(results)
				local applied = false
				for client_id, res in pairs(results or {}) do
					if res and res.error then
						vim.notify(
							string.format("Rename error (%s): %s", client_id, res.error.message or "unknown"),
							vim.log.levels.WARN
						)
					elseif (not applied) and res and res.result then
						local client = vim.lsp.get_client_by_id(client_id)
						vim.lsp.util.apply_workspace_edit(res.result, client and client.offset_encoding or "utf-16")
						applied = true
					end
				end

				if not applied then
					return
				end

				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.bo[buf].modified and not pre_modified[buf] then
						local name = vim.api.nvim_buf_get_name(buf)
						if name ~= "" and not vim.bo[buf].readonly and vim.bo[buf].buftype == "" then
							pcall(vim.fn.bufload, buf)
							pcall(vim.api.nvim_buf_call, buf, function()
								vim.cmd("silent noautocmd keepalt keepjumps write")
							end)
						end
					end
				end

				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if
						vim.api.nvim_buf_is_valid(buf)
						and vim.fn.bufwinid(buf) == -1
						and (not pre_existing[buf] or not pre_loaded[buf])
					then
						pcall(vim.api.nvim_buf_delete, buf, { force = true })
					end
				end
			end)
		end)
	end, { desc = "LSP Rename" })

	-- Toggle inlay hints
	vim.keymap.set("n", "<leader>ih", function()
		local bufnr = vim.api.nvim_get_current_buf()
		local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
		vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
	end, { desc = "Toggle inlay hints" })
end
