local servers = require 'goldsmith.lsp.servers'
local plugins = require 'goldsmith.plugins'
local config = require 'goldsmith.config'

local M = {}

local registered_servers = {}
local server_data = {}

-- yes, currently manually populated
local registered_plugins = { 'treesitter-textobjects' }

-- currently this is mostly the lspconfig defaults;
-- should mutate over time to be better / different
local on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(
    bufnr,
    'n',
    '<leader>wl',
    '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
    opts
  )
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting_seq_sync()<CR>', opts)
end

local config_map = {
  gopls = require 'goldsmith.autoconfig.lsp.gopls',
  null = require 'goldsmith.autoconfig.lsp.null',
}

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
    vim.api.nvim_err_writeln(string.format("Server configuration for server '%s' must be a table or function", server))
    return {}
  end
end

local function get_servers_to_configure()
  if #registered_servers > 0 then
    return registered_servers
  elseif config.is_autoconfig() then
    return servers.names()
  end
  return {}
end

function M.all_servers_are_running()
  local known_clients = {}
  for _, c in pairs(vim.lsp.get_active_clients()) do
    local ok, sn = servers.is_server(c.name)
    if ok then
      table.insert(known_clients, sn)
    end
  end
  for _, ks in ipairs(get_servers_to_configure()) do
    if not vim.tbl_contains(known_clients, ks) then
      return false
    end
  end
  return true
end

function M.init()
  require('goldsmith.tools').check()
  for _, s in ipairs(get_servers_to_configure()) do
    M.setup_server(s, get_server_conf(s))
  end
  for _, p in ipairs(registered_plugins) do
    M.setup_plugin(p)
  end
end

function M.setup_plugin(name)
  local ok, m = pcall(require, string.format('goldsmith.autoconfig.%s', name))
  if ok and m.has_requirements() then
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
    vim.api.nvim_err_writeln(string.format("Cannot determine how to configure '%s'", server))
  end
  if cf['on_attach'] == nil then
    cf['on_attach'] = on_attach
  end
  local sm = config_map[name]
  if sm.has_requirements() then
    sm.setup(cf)
  else
    vim.api.nvim_err_writeln(
      string.format("Server '%s' does not have all needed requirements and cannot be configured", server)
    )
  end
  if not sm.is_minimum_version() then
    local mv = servers.info(server).minimum_version
    vim.api.nvim_err_writeln(string.format("Server '%s' is not at the minimum required version (%s); some things may not work correctly", server, mv))
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
