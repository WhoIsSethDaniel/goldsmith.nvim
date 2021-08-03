-- see https://github.com/golang/tools/blob/master/gopls/doc/settings.md
-- for all settings for the most recent version of gopls;
-- see https://github.com/golang/tools/releases for a changelog
local util = require 'lspconfig.util'
local servers = require 'goldsmith.lsp.servers'
local plugins = require 'goldsmith.plugins'

local M = { _config = {} }

local SETTINGS = {
  gopls = {
    gofumpt = true,
    staticcheck = true,
    experimentalPostfixCompletions = true
  }
}

local FILETYPES = { 'go', 'gomod' }

local FLAGS = {
  debounce_text_changes = 500,
}

local function set_flags(flags)
  return vim.tbl_deep_extend('keep', flags, FLAGS)
end

local function set_server_settings(settings)
  return vim.tbl_deep_extend('keep', settings, SETTINGS)
end

local set_root_dir = function()
  return util.root_pattern('go.mod', '.git')
end

local function set_default_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- if the user wants to use postfixCompletions this is REQUIRED
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return capabilities
end

-- debug options:
-- '-logfile=auto',
-- '-rpc.trace'
local function set_command()
  return { servers.info('gopls').cmd, '-remote=auto' }
end

local function set_filetypes(ft)
  for _, filetype in ipairs(FILETYPES) do
    if not vim.tbl_contains(ft, filetype) then
      table.insert(ft, filetype)
    end
  end
  return ft
end

local function correct_server_conf_key()
  return servers.lsp_plugin_name 'gopls'
end

function M.has_config()
  if plugins.is_installed 'lspconfig' then
    return true
  end
  return false
end

function M.config()
  M._config['filetypes'] = set_filetypes(M._config['filetypes'] or {})
  M._config['flags'] = set_flags(M._config['flags'] or {})
  M._config['settings'] = set_server_settings(M._config['settings'] or {})
  if M._config['cmd'] == nil then
    M._config['cmd'] = set_command()
  end
  if M._config['root_dir'] == nil then
    M._config['root_dir'] = set_root_dir()
  end
  if M._config['capabilities'] == nil then
    M._config['capabilities'] = set_default_capabilities()
  end
  local server = correct_server_conf_key()
  require('lspconfig')[server].setup(M._config)
end

function M.setup(cf)
  M._config = cf or {}
end

return M
