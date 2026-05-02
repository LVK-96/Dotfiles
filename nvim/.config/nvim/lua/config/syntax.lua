local M = {}

function M.setup()
	vim.filetype.add({
		filename = {
			Jenkinsfile = "groovy",
		},
		extension = {
			bcf = "bcf",
			jsx = "typescript.tsx",
			n = "cpp",
			p = "cpp",
			sbt = "scala",
			sv = "systemverilog",
			sva = "systemverilog",
			tsx = "typescript.tsx",
			v = "verilog",
			wgsl = "wgsl",
		},
	})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "bcf",
		command = "setlocal commentstring=//\\ %s",
	})
end

return M
