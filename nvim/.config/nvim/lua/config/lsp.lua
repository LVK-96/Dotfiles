function lsp()
	local function enable_if_executable(name, config)
		vim.lsp.config(name, config)

		if type(config.cmd) == "table" and vim.fn.executable(config.cmd[1]) == 1 then
			vim.lsp.enable(name)
		end
	end

	enable_if_executable("ty", {
		cmd = { "ty", "server" },
		filetypes = { "python" },
		root_markers = { "pyproject.toml", ".git" },
	})

	vim.lsp.config("clangd", {
		cmd = { "chess-clangd" },
		autostart = false,
	})

	enable_if_executable("verible", {
		cmd = { "verible-verilog-ls", "--rules_config_search" },
		filetypes = { "verilog", "systemverilog" },
		root_markers = { ".git", "flake.nix" },
	})

	local group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })

	vim.api.nvim_create_autocmd("LspAttach", {
		group = group,
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client and client:supports_method("textDocument/completion") then
				vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
			end
		end,
	})

	vim.diagnostic.config({
		virtual_text = false,
		signs = true,
		underline = true,
		update_in_insert = false,
		float = {
			source = "always",
		},
	})

	vim.api.nvim_create_autocmd("CursorHold", {
		group = group,
		callback = function()
			vim.diagnostic.open_float(nil, {
				focusable = false,
				close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
				source = "always",
				prefix = " ",
				scope = "cursor",
			})
		end,
	})
end
