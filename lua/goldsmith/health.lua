local tools = require("goldsmith.tools")
local servers = require("goldsmith.lsp.servers")
local plugins = require("goldsmith.plugins")

local health_start = vim.fn["health#report_start"]
local health_ok = vim.fn["health#report_ok"]
local health_error = vim.fn["health#report_error"]
local health_warn = vim.fn["health#report_warn"]

local M = {}

function M.lsp_plugin_check()
	health_start("Plugin Check")

	plugins.check()
	for _, plugin in ipairs(plugins.names()) do
		if plugins.is_installed(plugin) then
			health_ok(string.format("%s: plugin is installed", plugin))
		elseif plugins.is_required(plugin) then
			health_error(string.format("%s: NOT INSTALLED and is REQUIRED", plugin), { "Please install this module." })
		else
			health_warn(string.format("%s: NOT INSTALLED and is OPTIONAL", plugin), {})
		end
	end
end

function M.lsp_server_check()
	health_start("LSP Server Check")

	servers.check()
	for _, server in ipairs(servers.names()) do
		local si = servers.info(server)
		if servers.is_installed(server) then
			health_ok(string.format("%s: server is installed via %s at %s", si.name, si.via, si.cmd))
		elseif servers.is_required(server) then
			health_error(
				string.format("%s: NOT INSTALLED and is REQUIRED", si.name),
				{ "This server should be installed." }
			)
		else
			health_warn(string.format("%s: NOT INSTALLED and is OPTIONAL", si.name), {})
		end
	end
end

function M.tool_check()
	health_start("Tool Check")

	tools.check()
	for _, tool in ipairs(tools.names()) do
		local ti = tools.info(tool)
		if ti.cmd == nil then
			health_warn(string.format("%s: MISSING", tool), ti.not_found)
		else
			health_ok(string.format("%s: FOUND at %s (%s)", tool, ti.cmd, ti.version))
		end
	end
end

function M.check()
	M.lsp_plugin_check()
	M.lsp_server_check()
	M.tool_check()
end

return M
