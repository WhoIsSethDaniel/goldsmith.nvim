local tools = require 'goldsmith.tools'
local servers = require 'goldsmith.lsp.servers'
local plugins = require 'goldsmith.plugins'
local ac = require 'goldsmith.autoconfig'
local health = require 'vim.health'

local M = {}

function M.go_check()
  health.report_start 'Go Check'

  tools.check()
  local tool = 'go'
  local ti = tools.info(tool)
  if ti.cmd == nil then
    health.report_error(string.format('%s: MISSING', tool), ti.not_found)
  else
    health.report_ok(string.format('%s: FOUND at %s (%s)', tool, ti.cmd, ti.version))
  end
end

function M.plugin_check()
  health.report_start 'Plugin Check'

  plugins.check()
  for _, plugin in ipairs(plugins.names()) do
    local advice = {}
    local pi = plugins.info(plugin)
    local name = pi.name
    vim.list_extend(advice, pi.not_found)
    table.insert(advice, string.format('The module is here: %s', pi.location))
    if plugins.is_installed(plugin) then
      health.report_ok(string.format('%s: plugin is installed', name))
    elseif plugins.is_required(plugin) then
      table.insert(advice, 'Please install this module.')
      health.report_error(string.format('%s: NOT INSTALLED and is REQUIRED', name), advice)
    else
      health.report_warn(string.format('%s: NOT INSTALLED and is OPTIONAL', name), advice)
    end
  end
end

function M.lsp_server_check()
  health.report_start 'LSP Server Check'

  servers.check()
  for _, server in ipairs(servers.names()) do
    local si = servers.info(server)
    if si.exe ~= nil and si.plugin ~= true then
      if servers.is_installed(server) then
        health.report_ok(string.format('%s: server is installed via %s at %s', si.exe, si.via, si.cmd))
      elseif servers.is_required(server) then
        health.report_error(
          string.format('%s: NOT INSTALLED and is REQUIRED', si.exe),
          { 'This server should be installed.' }
        )
      else
        health.report_warn(string.format('%s: NOT INSTALLED and is OPTIONAL', si.exe), {})
      end
    end
  end
end

function M.lsp_server_config_check()
  health.report_start 'LSP Server Config Check'

  if ac.autoconfig_is_on() then
    health.report_ok 'Goldsmith autoconfig is turned on'
  else
    health.report_ok 'Goldsmith autoconfig is turned off'
  end
  local running = {}
  local s = ac.get_configured_servers()
  ac.map(function(name, m)
    if not vim.tbl_contains(s, name) then
      return
    end
    table.insert(running, name)
    if m['running_services'] ~= nil then
      table.insert(s, m.running_services())
      s = vim.tbl_flatten(s)
    end
  end)
  health.report_ok(string.format('Servers/Services Goldsmith has configured: %s', table.concat(running, ', ')))
end

function M.tool_check()
  health.report_start 'Tool Check'

  tools.check()
  for _, tool in ipairs(tools.names { status = 'install' }) do
    local not_found = {}
    local ti = tools.info(tool)
    if ti.cmd == nil then
      if ti.status == 'install' then
        vim.list_extend(not_found, ti.not_found)
        table.insert(not_found, string.format("It may be installed by running ':GoInstallBinaries %s'", tool))
      end
      health.report_warn(string.format('%s: MISSING', ti.exe), not_found)
    else
      health.report_ok(string.format('%s: FOUND at %s (%s)', ti.exe, ti.cmd, ti.version))
    end
  end
end

function M.check()
  M.go_check()
  M.plugin_check()
  M.lsp_server_check()
  M.lsp_server_config_check()
  M.tool_check()
end

return M
