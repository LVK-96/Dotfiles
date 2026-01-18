function lsp()
	vim.lsp.config("pyright", {})

	vim.lsp.config("clangd", {
		cmd = { "chess-clangd" },
		autostart = false,
	})

	vim.lsp.config("verible", {
		cmd = { "verible-verilog-ls", "--rules_config_search" },
		autostart = false,
	})

	vim.lsp.enable("python", "rust", "cpp", "c", "verilog")
end
