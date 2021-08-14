local plugins = require 'goldsmith.plugins'
local config = require 'goldsmith.config'
local tools = require 'goldsmith.tools'
local servers = require 'goldsmith.lsp.servers'

local null = require 'null-ls'

local M = {}

local running_services = {}

local function service_module(name)
  return require(string.format('goldsmith.autoconfig.lsp.null.%s', name))
end

function M.supported_filetypes()
  return servers.info('null').filetypes
end

function M.is_minimum_version()
  return true
end

function M.has_requirements()
  if plugins.is_installed 'null' then
    return true
  end
  return false
end

function M.services()
  return tools.names({ null = true })
end

function M.running_services()
  local rs = {}
  for _, v in pairs(running_services) do
    table.insert(rs, v.name)
  end
  return rs
end

function M.is_disabled(service)
  local disabled = config.get('null', 'disabled')
  if type(disabled) == 'boolean' and disabled == true then
    return true
  elseif type(disabled) == 'table' then
    if vim.tbl_isempty(disabled) then
      return true
    end
    if vim.tbl_contains(disabled, service) then
      return true
    end
  end
  return false
end

function M.loadtime_check()
  for _, s in ipairs(M.running_services()) do
    service_module(s).check_and_warn_about_requirements()
  end
end

function M.setup(cf)
  for _, service in ipairs(M.services()) do
    local m = service_module(service)
    if m.has_requirements() and not M.is_disabled(service) then
      table.insert(running_services, m.setup())
    end
  end
  null.config(cf)
  null.register(running_services)
  require('lspconfig')['null-ls'].setup(cf)
end

return M
