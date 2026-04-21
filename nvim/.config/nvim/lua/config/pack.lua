local M = {}

local function notify_error(message)
	vim.schedule(function()
		vim.notify(message, vim.log.levels.ERROR)
	end)
end

local function after_start(callback)
	if vim.v.vim_did_enter == 1 then
		vim.schedule(callback)
		return
	end

	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = callback,
	})
end

local function setup_treesitter_update_hook()
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			local data = ev.data or {}
			local spec = data.spec or {}
			if spec.name ~= "nvim-treesitter" or (data.kind ~= "install" and data.kind ~= "update") then
				return
			end

			after_start(function()
				local ok, err = pcall(function()
					vim.cmd.packadd("nvim-treesitter")
					vim.cmd.TSUpdate()
				end)
				if not ok then
					notify_error("Pack build failed for nvim-treesitter: " .. err)
				end
			end)
		end,
	})
end

local function setup_commands()
	vim.api.nvim_create_user_command("PackUpdate", function(opts)
		vim.pack.update(#opts.fargs > 0 and opts.fargs or nil)
	end, {
		nargs = "*",
		desc = "Update vim.pack plugins",
	})

	vim.api.nvim_create_user_command("PackClean", function()
		local inactive = vim.iter(vim.pack.get(nil, { info = false }))
			:filter(function(plugin)
				return not plugin.active
			end)
			:map(function(plugin)
				return plugin.spec.name
			end)
			:totable()

		if #inactive == 0 then
			vim.notify("No inactive vim.pack plugins to remove", vim.log.levels.INFO)
			return
		end

		vim.pack.del(inactive)
	end, {
		desc = "Remove inactive vim.pack plugins",
	})
end

function M.setup()
	if not vim.pack then
		error("vim.pack requires Neovim 0.12 or newer")
	end

	vim.g.mapleader = " "
	vim.g.maplocalleader = "\\"

	local plugin_config = require("config.plugin_config")
	plugin_config.init()

	setup_treesitter_update_hook()
	vim.pack.add(require("config.plugins"), { confirm = false, load = false })
	plugin_config.setup()
	setup_commands()
end

M.setup()

return M
