local plugins = require("goldsmith.lsp.plugins")
local tools = require("goldsmith.tools")

local M = {}

local servers = {
	gopls = {
		required = true,
		name = "gopls",
		lspconfig_name = "gopls",
		lspinstall_name = "go",
	},
	efm = {
		required = false,
		name = "efm-langserver",
		lspconfig_name = "efm",
		lspinstall_name = "efm",
	},
}

function M.check()
	for s, m in pairs(servers) do
		servers[s].installed = false
		local li_installed = false
		local li_util
		if plugins.is_installed("lspinstall") then
			local li = require("lspinstall")
			li_util = require("lspinstall.util")
			li_installed = li.is_server_installed(m.lspinstall_name)
		end
		if li_installed then
			servers[s].installed = true
			servers[s].via = "lspinstall"
			local cmd = string.format("%s/%s", li_util.install_path(m.lspinstall_name), m.name)
			if vim.fn.filereadable(cmd) ~= 0 then
				servers[s].cmd = cmd
			end
		else
			local check = tools.check({ m.name })
			if check[m.name].exec ~= "" then
				servers[s].installed = true
				servers[s].via = "user installation"
				servers[s].cmd = check[m.name].exec
			end
		end
	end
	return M
end

function M.all_servers()
	local names = {}
	for s, _ in pairs(servers) do
		table.insert(names, s)
	end
	return names
end

function M.is_required(server)
	return servers[server].required
end

function M.is_installed(server)
	if servers[server].installed then
		return servers[server]
	end
	return false
end

function M.server_info(server)
	if servers[server] ~= nil then
		return servers[server]
	end
	return nil
end

function M.dump()
	print(vim.inspect(servers))
end

return M
