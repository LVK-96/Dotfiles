local M = {}

local function notify_error(message)
	vim.schedule(function()
		vim.notify(message, vim.log.levels.ERROR)
	end)
end

function M.safe(name, callback)
	local ok, err = pcall(callback)
	if not ok then
		notify_error(string.format("Plugin config failed for %s: %s", name, err))
	end
end

return M
