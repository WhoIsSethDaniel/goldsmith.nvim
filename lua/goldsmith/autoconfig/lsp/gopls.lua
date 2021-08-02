-- see https://github.com/golang/tools/blob/master/gopls/doc/settings.md
-- for all settings for the most recent version of gopls;
-- see https://github.com/golang/tools/releases for a changelog
local util = require 'lspconfig.util'
local servers = require 'goldsmith.lsp.servers'
local plugins = require 'goldsmith.plugins'

local M = { _config = {} }

local CONFIG_DEFAULTS = {
  gofumpt = true,
  staticcheck = true,
}

local FILETYPES = { 'go', 'gomod' }

local DEFAULTS = {
  flags = {
    debounce_text_changes = 500,
  },
  settings = {
    gopls = CONFIG_DEFAULTS,
  },
}

local set_root_dir = function()
    return util.root_pattern('go.mod', '.git')
end

local set_default_capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- if the user wants to use postfixCompletions this is REQUIRED
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return capabilities
end

-- debug options:
-- '-logfile=auto',
-- '-rpc.trace'
local set_command = function()
  return { servers.info('gopls').cmd, '-remote=auto' }
end

local set_filetypes = function(ft)
  local t = vim.tbl_values(ft or {})
  for _, filetype in ipairs(FILETYPES) do
    if not vim.tbl_contains(t, filetype) then
      table.insert(t, filetype)
    end
  end
  return t
end

local correct_server_conf_key = function()
  return servers.lsp_plugin_name 'gopls'
end

function M.has_config()
  if plugins.is_installed 'lspconfig' then
    return true
  end
  return false
end

function M.config()
  local server = correct_server_conf_key()
  require('lspconfig')[server].setup(M._config)
end

function M.setup(cf)
  M._config = cf or {}
  M._config['cmd'] = set_command(cf['cmd'] or {})
  M._config['filetypes'] = set_filetypes(cf['filetypes'] or {})
  M._config['flags'] = vim.tbl_extend('keep', cf['flags'] or {}, DEFAULTS.flags)
  M._config['settings'] = vim.tbl_deep_extend('keep', cf['settings'] or {}, DEFAULTS.settings)
  if cf['root_dir'] == nil then
    M._config['root_dir'] = set_root_dir()
  end
  if cf['capabilities'] == nil then
    M._config['capabilities'] = set_default_capabilities()
  end
end

return M
