local M = {}

local configured = {}

local function notify_error(message)
	vim.schedule(function()
		vim.notify(message, vim.log.levels.ERROR)
	end)
end

local function packadd(plugin)
	local ok, err = pcall(vim.cmd.packadd, plugin)
	if not ok then
		notify_error(string.format("Failed to load plugin %s: %s", plugin, err))
		return false
	end
	return true
end

function M.setup_once(plugin, setup)
	if configured[plugin] then
		return true
	end

	if not packadd(plugin) then
		return false
	end

	if setup then
		local ok, err = pcall(setup)
		if not ok then
			notify_error(string.format("Plugin config failed for %s: %s", plugin, err))
			return false
		end
	end

	configured[plugin] = true
	return true
end

function M.run(plugin, setup, callback)
	if not M.setup_once(plugin, setup) then
		return nil
	end

	if callback then
		return callback()
	end
end

function M.map(mode, lhs, plugin, setup, callback, opts)
	opts = opts or {}
	vim.keymap.set(mode, lhs, function()
		return M.run(plugin, setup, callback)
	end, opts)
end

function M.command(name, plugin, setup, callback, opts)
	opts = opts or {}
	vim.api.nvim_create_user_command(name, function(command_opts)
		pcall(vim.api.nvim_del_user_command, name)
		M.run(plugin, setup, function()
			callback(command_opts)
		end)
	end, opts)
end

function M.on_event(events, plugin, setup, opts)
	opts = opts or {}
	local group = vim.api.nvim_create_augroup("UserLazy" .. plugin:gsub("%W", ""), { clear = true })
	vim.api.nvim_create_autocmd(
		events,
		vim.tbl_extend("force", opts, {
			group = group,
			callback = function(ev)
				M.setup_once(plugin, setup)
				if opts.callback then
					opts.callback(ev)
				end
			end,
		})
	)
end

return M
