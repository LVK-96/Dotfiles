local M = {}

function M.enabled()
	return vim.g.vscode == 1 or vim.g.vscode == true
end

function M.call(command)
	if not M.enabled() then
		return false
	end

	local ok, vscode = pcall(require, "vscode")
	if not ok then
		vim.notify("VSCode-Neovim module is not available", vim.log.levels.WARN)
		return false
	end

	vscode.call(command)
	return true
end

function M.open_editor_at_index(index)
	return M.call("workbench.action.openEditorAtIndex" .. index)
end

function M.next_editor()
	return M.call("workbench.action.nextEditor")
end

function M.previous_editor()
	return M.call("workbench.action.previousEditor")
end

function M.close_active_editor()
	return M.call("workbench.action.closeActiveEditor")
end

return M
