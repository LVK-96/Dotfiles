function lsp()
	vim.lsp.config("ty", {
		cmd = { "ty", "server" },
		filetypes = { "python" },
		root_markers = { "pyproject.toml", ".git" },
	})

	vim.lsp.config("clangd", {
		cmd = { "chess-clangd" },
		autostart = false,
	})

	vim.lsp.config("verible", {
		cmd = { "verible-verilog-ls", "--rules_config_search" },
		filetypes = { "verilog", "systemverilog" },
		root_markers = { ".git", "flake.nix" },
	})

	vim.lsp.enable({ "ty", "verible" })
end
