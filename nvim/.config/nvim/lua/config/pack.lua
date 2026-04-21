local M = {}

local github_prefix = "https://github.com/"

local function plugin_name(src)
	local name = src:match("([^/]+)$") or src
	return (name:gsub("%.git$", ""))
end

local function plugin_src(spec)
	local src = spec.src or spec[1]
	if src:match("^[%w+.-]+://") or src:match("^git@") then
		return src
	end
	return github_prefix .. src
end

local function enabled(spec)
	if spec.enabled == nil then
		return true
	end
	if type(spec.enabled) == "function" then
		local ok, result = pcall(spec.enabled)
		return ok and result
	end
	return spec.enabled
end

local function as_list(value)
	if value == nil then
		return {}
	end
	if type(value) == "string" then
		return { value }
	end
	if type(value) == "table" and type(value[1]) == "string" then
		for key in pairs(value) do
			if type(key) ~= "number" then
				return { value }
			end
		end
	end
	return value
end

local function normalize(spec)
	if type(spec) == "string" then
		spec = { spec }
	end
	if type(spec) ~= "table" or (type(spec[1]) ~= "string" and type(spec.src) ~= "string") then
		return nil
	end

	spec.src = plugin_src(spec)
	spec.name = spec.name or plugin_name(spec.src)
	return spec
end

local function pack_version(version)
	if version == nil or version == false then
		return nil
	end
	if type(version) ~= "string" then
		return version
	end
	if version == "*" or version:match("^[~^<>=]") or version:match("^%d") then
		local ok, range = pcall(vim.version.range, version)
		if ok then
			return range
		end
	end
	return version
end

local function module_name(spec)
	if spec.main then
		return spec.main
	end

	return spec.name:gsub("%.nvim$", ""):gsub("%.lua$", "")
end

local function notify_error(message)
	vim.schedule(function()
		vim.notify(message, vim.log.levels.ERROR)
	end)
end

local function run_build(name, build, path)
	local function runner()
		local ok, err = pcall(function()
			if type(build) == "function" then
				build(path)
			elseif build:sub(1, 1) == ":" then
				vim.cmd(build:sub(2))
			else
				vim.system(vim.split(build, "%s+"), { cwd = path })
			end
		end)

		if not ok then
			notify_error(string.format("Pack build failed for %s: %s", name, err))
		end
	end

	if vim.v.vim_did_enter == 1 then
		vim.schedule(runner)
	else
		vim.api.nvim_create_autocmd("VimEnter", {
			once = true,
			callback = runner,
		})
	end
end

local function setup_build_hooks(build_hooks)
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			local data = ev.data or {}
			if data.kind ~= "install" and data.kind ~= "update" then
				return
			end

			local spec = data.spec or {}
			local name = spec.name
			local build = name and build_hooks[name]
			if build then
				run_build(name, build, data.path)
			end
		end,
	})
end

local function run_init(spec)
	if type(spec.init) ~= "function" then
		return
	end

	local ok, err = pcall(spec.init)
	if not ok then
		notify_error(string.format("Pack init failed for %s: %s", spec.name, err))
	end
end

local function configure(spec)
	local config = spec.config
	if config == false then
		return
	end

	local ok, err = pcall(function()
		if type(config) == "function" then
			config()
		elseif config == true or spec.opts ~= nil then
			local plugin = require(module_name(spec))
			if type(plugin.setup) == "function" then
				plugin.setup(spec.opts or {})
			end
		end
	end)

	if not ok then
		notify_error(string.format("Pack config failed for %s: %s", spec.name, err))
	end
end

local function keymap_opts(key)
	local opts = {}
	for name, value in pairs(key) do
		if type(name) ~= "number" and name ~= "mode" then
			opts[name] = value
		end
	end
	return opts
end

local function setup_keymaps(spec)
	for _, key in ipairs(as_list(spec.keys)) do
		if type(key) == "table" and key[1] and key[2] then
			vim.keymap.set(key.mode or "n", key[1], key[2], keymap_opts(key))
		end
	end
end

local function collect_specs()
	local specs = {}
	local seen = {}
	local build_hooks = {}

	local function add(raw_spec)
		local spec = normalize(raw_spec)
		if not spec or not enabled(spec) then
			return
		end

		for _, dependency in ipairs(as_list(spec.dependencies)) do
			add(dependency)
		end

		if seen[spec.name] then
			return
		end

		seen[spec.name] = true
		specs[#specs + 1] = spec

		if spec.build then
			build_hooks[spec.name] = spec.build
		end
	end

	for _, spec in ipairs(require("config.plugins")) do
		add(spec)
	end

	return specs, build_hooks
end

local function setup_commands()
	vim.api.nvim_create_user_command("PackUpdate", function(opts)
		local names = #opts.fargs > 0 and opts.fargs or nil
		vim.pack.update(names)
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

	local specs, build_hooks = collect_specs()
	setup_build_hooks(build_hooks)

	for _, spec in ipairs(specs) do
		run_init(spec)
	end

	vim.pack.add(
		vim.iter(specs)
			:map(function(spec)
				return {
					src = spec.src,
					name = spec.name,
					version = pack_version(spec.version),
				}
			end)
			:totable(),
		{ confirm = false, load = false }
	)

	for _, spec in ipairs(specs) do
		configure(spec)
		setup_keymaps(spec)
	end

	setup_commands()
end

M.setup()

return M
