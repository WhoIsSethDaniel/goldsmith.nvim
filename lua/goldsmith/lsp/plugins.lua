local M = {}

local plugins = {
	lspconfig = {
		required = true,
		installed = false,
		check_installed = function()
			return vim.g.lspconfig
		end,
	},
	lspinstall = {
		required = false,
		installed = false,
		check_installed = function()
			return vim.fn.exists("*lspinstall#installed_servers")
		end,
	},
}

function M.all_plugins()
	local names = {}
	for s, _ in pairs(plugins) do
		table.insert(names, s)
	end
	return names
end

function M.check()
	for _, pm in pairs(plugins) do
		pm.installed = pm.check_installed()
	end
	return M
end

function M.is_required(plugin)
	return plugins[plugin].required
end

function M.is_installed(plugin)
	return plugins[plugin].installed
end

function M.dump()
	print(vim.inspect(plugins))
end

return M
