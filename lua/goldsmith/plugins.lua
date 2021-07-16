local M = {}

local PLUGINS = {
	lspconfig = {
		required = true,
		installed = false,
		check_installed = function()
			return vim.g.lspconfig == 1
		end,
	},
	lspinstall = {
		required = false,
		installed = false,
		check_installed = function()
			return vim.fn.exists("*lspinstall#installed_servers") == 1
		end,
	},
	asyncrun = {
		required = true,
		installed = false,
		check_installed = function()
			return vim.fn.exists(":AsyncRun") == 2
		end,
	},
}

function M.names()
	local names = {}
	for s, _ in pairs(PLUGINS) do
		table.insert(names, s)
	end
	return names
end

function M.check()
	for _, pm in pairs(PLUGINS) do
		pm.installed = pm.check_installed()
	end
	return M
end

function M.info(plugin)
	return PLUGINS[plugin]
end

function M.is_required(plugin)
	return PLUGINS[plugin].required
end

function M.is_installed(plugin)
	return PLUGINS[plugin].installed
end

function M.dump()
	print(vim.inspect(PLUGINS))
end

return M
