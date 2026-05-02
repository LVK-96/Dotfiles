local M = {}

local util = require("config.plugins.util")

local function setup_mini_modules()
	local mini_modules = {
		"ai",
		"align",
		"comment",
		"move",
		"operators",
		"pairs",
		"splitjoin",
	}

	for _, module in ipairs(mini_modules) do
		util.safe("mini." .. module, function()
			local mini_module = require("mini." .. module)
			mini_module.setup({})

			if module == "pairs" then
				vim.api.nvim_create_autocmd("FileType", {
					pattern = { "verilog", "systemverilog" },
					callback = function(ev)
						vim.keymap.set("i", "'", "'", { buffer = ev.buf })
					end,
				})
			end
		end)
	end

	util.safe("mini.snippets", function()
		local snippets = require("mini.snippets")
		snippets.setup({
			snippets = {
				snippets.gen_loader.from_lang(),
			},
		})
	end)
end

local function setup_blink_cmp()
	util.safe("blink.cmp", function()
		local blink = require("blink.cmp")
		local build_ok, build_err = pcall(function()
			blink.build():wait(60000)
		end)
		if not build_ok then
			vim.schedule(function()
				vim.notify(
					"blink.cmp native build failed, continuing without native fuzzy: " .. tostring(build_err),
					vim.log.levels.WARN
				)
			end)
		end

		blink.setup({
			keymap = {
				preset = "none",
				["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
				["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide", "fallback" },
			},
			completion = {
				documentation = {
					auto_show = false,
				},
			},
			snippets = {
				preset = "mini_snippets",
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			fuzzy = {
				implementation = "prefer_rust_with_warning",
			},
		})
	end)
end

function M.setup(opts)
	opts = opts or {}

	setup_mini_modules()
	if opts.completion then
		setup_blink_cmp()
	end
end

return M
