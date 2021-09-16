local plugins = require 'goldsmith.plugins'
local config = require 'goldsmith.config'
local tools = require 'goldsmith.tools'
local servers = require 'goldsmith.lsp.servers'
local log = require 'goldsmith.log'

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

function M.map(f)
  for _, s in ipairs(M.services()) do
    local m = service_module(s)
    f(s, m)
  end
end

function M.services()
  return tools.names { null = true }
end

function M.running_services()
  local rs = {}
  for _, v in pairs(running_services) do
    table.insert(rs, v.name)
  end
  return rs
end

function M.is_disabled(service)
  if config.get('null', 'enabled') == false then
    return true
  end
  if service ~= nil then
    return config.service_is_disabled(service)
  end
  return false
end

function M.setup(cf)
  local null = require 'null-ls'
  for _, service in ipairs(M.services()) do
    local m = service_module(service)
    if not M.is_disabled(service) then
      if m.has_requirements() then
        local setup
        local user_args = config.get('null', service)
        if type(user_args) == 'table' then
          setup = m.setup(user_args)
        else
          setup = m.setup {}
        end
        table.insert(running_services, setup)
        null.register(setup)
      else
        log.warn(
          'Null',
          string.format(
            "'%s' is not installed. Any service that requires it will not function. Run ':checkhealth goldsmith' for more.",
            service
          )
        )
      end
    end
  end
  null.config(cf)
  return cf
end

return M
