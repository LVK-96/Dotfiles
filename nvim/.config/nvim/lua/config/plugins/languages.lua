local M = {}

local util = require("config.plugins.util")

local function setup_treesitter()
	util.safe("nvim-treesitter", function()
		local status_ok = pcall(require, "nvim-treesitter.configs")
		if not status_ok then
			return
		end

		require("nvim-treesitter.configs").setup({
			sync_install = false,
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = {
				enable = true,
			},
			matchup = {
				enable = true,
			},
			ensure_installed = {
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
			},
		})
	end)
end

local function setup_rustaceanvim()
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

local function setup_metals()
	util.safe("nvim-metals", function()
		local metals = require("metals")
		local metals_config = metals.bare_config()
		metals_config.on_attach = function(client, bufnr)
			if client:supports_method("textDocument/inlayHint") then
				pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
			end
		end

		local group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "scala", "sbt", "java" },
			callback = function()
				metals.initialize_or_attach(metals_config)
			end,
			group = group,
		})
	end)
end

function M.setup()
	setup_treesitter()
	setup_rustaceanvim()
	setup_metals()
end

return M
