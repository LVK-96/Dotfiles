local M = {}

local lazy = require("config.plugins.lazy")

local treesitter_filetypes = {
	"bash",
	"c",
	"cpp",
	"css",
	"html",
	"javascript",
	"json",
	"lua",
	"markdown",
	"python",
	"rust",
	"toml",
	"typescript",
	"yaml",
}

local function configure_treesitter()
	local ok, treesitter = pcall(require, "nvim-treesitter")
	if not ok then
		return
	end

	treesitter.setup({
		install_dir = vim.fn.stdpath("data") .. "/site",
	})

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("UserTreesitterStart", { clear = true }),
		pattern = treesitter_filetypes,
		callback = function()
			pcall(vim.treesitter.start)
			pcall(function()
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end)
		end,
	})
end

local function configure_rustaceanvim()
	vim.g.rustaceanvim = {
		server = {
			settings = {
				["rust-analyzer"] = {
					cargo = {
						allFeatures = true,
						loadOutDirsFromCheck = true,
						buildScripts = {
							enable = true,
						},
					},
					checkOnSave = {
						allFeatures = true,
						command = "clippy",
						extraArgs = { "--no-deps" },
					},
					procMacro = {
						enable = true,
						ignored = {
							["async-trait"] = { "async_trait" },
							["napi-derive"] = { "napi" },
							["async-recursion"] = { "async_recursion" },
						},
					},
					inlayHints = {
						typeHints = { enable = true },
						parameterHints = { enable = true },
						chainingHints = { enable = false },
					},
				},
			},
			on_attach = function(client, bufnr)
				if client:supports_method("textDocument/inlayHint") then
					pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
				end
			end,
		},
	}
end

local function configure_metals()
	local metals = require("metals")
	local metals_config = metals.bare_config()
	metals_config.on_attach = function(client, bufnr)
		if client:supports_method("textDocument/inlayHint") then
			pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
		end
	end

	metals.initialize_or_attach(metals_config)
end

local function setup_rustaceanvim()
	configure_rustaceanvim()
	lazy.on_event("FileType", "rustaceanvim", nil, {
		pattern = { "rust" },
	})
end

local function setup_metals()
	lazy.on_event("FileType", "nvim-metals", configure_metals, {
		pattern = { "scala", "sbt", "java" },
	})
end

function M.setup()
	configure_treesitter()
	setup_rustaceanvim()
	setup_metals()
end

return M
