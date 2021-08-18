local servers = require 'goldsmith.lsp.servers'
local plugins = require 'goldsmith.plugins'
local config = require 'goldsmith.config'
local log = require 'goldsmith.log'

local M = {}

local registered_servers = {}
local server_data = {}

-- yes, currently manually populated
local registered_plugins = { 'treesitter-textobjects' }

local on_attach = function(client, bufnr)
  require'goldsmith.mappings'.set_buffer_mappings(bufnr)
end

local function server_module(server)
  return require(string.format('goldsmith.autoconfig.lsp.%s', servers.info(server).module_name))
end

local function plugin_module(plugin)
  return require(string.format('goldsmith.autoconfig.%s', plugin))
end

local function get_server_conf(server)
  local cf
  if server_data[server] ~= nil then
    cf = server_data[server]
  else
    cf = config.get(server, 'config')
  end
  if cf == nil then
    return {}
  end
  if type(cf) == 'function' then
    return cf()
  elseif type(cf) == 'table' then
    return cf
  else
    log.error(nil, string.format("Server configuration for server '%s' must be a table or function", server))
    return {}
  end
end

local function get_plugins_to_configure()
  return registered_plugins
end

local function get_servers_to_configure()
  local potential = {}
  if #registered_servers > 0 then
    potential = registered_servers
  elseif M.autoconfig_is_on() then
    potential = M.get_all_servers()
  end
  local s = {}
  for _, server in ipairs(potential) do
    if not server_module(server).is_disabled() then
      table.insert(s, server)
    end
  end
  return s
end

local function all_servers_for_filetype(type)
  local s = {}
  for _, server in ipairs(M.get_all_servers()) do
    local fts = server_module(server).supported_filetypes()
    if vim.tbl_contains(fts, type) then
      table.insert(s, server)
    end
  end
  return s
end

local function all_configured_servers_for_filetype(type)
  local s = {}
  local sft = all_servers_for_filetype(type)
  local configured = M.get_configured_servers()
  for _, server in ipairs(configured) do
    if vim.tbl_contains(sft, server) then
      table.insert(s, server)
    end
  end
  return s
end

local set_root_dir = function(fname)
  local util = require('lspconfig.util')
  return util.root_pattern('go.work', 'go.mod', '.git')(fname) or util.path.dirname(fname)
end

M.autoconfig_is_on = config.autoconfig_is_on

M.get_all_plugins = get_plugins_to_configure

M.get_all_servers = servers.names

function M.get_configured_plugins()
  return get_plugins_to_configure()
end

function M.get_configured_servers()
  return get_servers_to_configure()
end

function M.map(f)
  for _, s in ipairs(M.get_all_servers()) do
    local m = server_module(s)
    if m['map'] == nil then
      f(s,m)
    else
      f(s,m)
      m.map(f)
    end
  end
  for _, p in ipairs(M.get_all_plugins()) do
    local m = plugin_module(p)
    f(p,m)
  end
end

function M.all_servers_are_running()
  local known_clients = {}
  for _, c in pairs(vim.lsp.get_active_clients()) do
    local ok, sn = servers.is_server(c.name)
    if ok then
      table.insert(known_clients, sn)
    end
  end
  local names = all_configured_servers_for_filetype(vim.opt.filetype:get())
  for _, ks in ipairs(names) do
    if not vim.tbl_contains(known_clients, ks) then
      return false
    end
  end
  return true
end

function M.loadtime_check()
  for _, s in ipairs(M.get_configured_servers()) do
    server_module(s).loadtime_check()
  end
end

function M.init()
  require('goldsmith.tools').check()
  for _, s in ipairs(get_servers_to_configure()) do
    M.setup_server(s, get_server_conf(s))
  end
  for _, p in ipairs(get_plugins_to_configure()) do
    M.setup_plugin(p)
  end
end

function M.setup_plugin(name)
  local m = plugin_module(name)
  if m.has_requirements() then
    m.setup()
  end
end

function M.setup_server(server, cf)
  local name
  local i = plugins.info(server)
  if i == nil then
    local ok, pn = servers.is_server(server)
    if ok then
      name = pn
    end
  else
    name = server
  end
  if name == nil then
    log.error(nil, string.format("Cannot determine how to configure '%s'", server))
  end
  if cf['on_attach'] == nil then
    cf['on_attach'] = on_attach
  end
  if cf['root_dir'] == nil then
    cf['root_dir'] = set_root_dir
  end
  local sm = server_module(name)
  if sm.has_requirements() then
    sm.setup(cf)
  else
    log.error(
      nil,
      string.format("Server '%s' does not have all needed requirements and cannot be configured", server)
    )
  end
  if not sm.is_minimum_version() then
    local mv = servers.info(server).minimum_version
    log.error(
      nil,
      string.format(
        "Server '%s' is not at the minimum required version (%s); some things may not work correctly",
        server,
        mv
      )
    )
  end
end

function M.register_server(server, cf)
  config.turn_off_autoconfig()
  local ok, sn = servers.is_server(server)
  if ok then
    if not vim.tbl_contains(registered_servers, sn) then
      table.insert(registered_servers, sn)
      server_data[sn] = cf
    end
    return true
  end
  return false
end

return M
