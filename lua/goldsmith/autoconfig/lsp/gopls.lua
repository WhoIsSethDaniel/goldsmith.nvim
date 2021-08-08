-- see https://github.com/golang/tools/blob/master/gopls/doc/settings.md
-- for all settings for the most recent version of gopls;
-- see https://github.com/golang/tools/releases for a changelog
local util = require 'lspconfig.util'
local servers = require 'goldsmith.lsp.servers'
local plugins = require 'goldsmith.plugins'
local config = require 'goldsmith.config'

local M = {}

local SETTINGS = {
  gopls = {
    gofumpt = true,
    staticcheck = true,
    usePlaceholders = true,
    diagnosticsDelay = '500ms',
    experimentalPostfixCompletions = true,
    experimentalUseInvalidMetadata = true,
    codelenses = {
      gc_details = true,
    },
  },
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

function M.has_requirements()
  if plugins.is_installed 'lspconfig' then
    return true
  end
  return false
end

function M.setup(cf)
  local conf = {}
  conf['filetypes'] = set_filetypes(cf['filetypes'] or {})
  conf['flags'] = set_flags(cf['flags'] or {})
  conf['settings'] = set_server_settings(cf['settings'] or {})
  if conf['cmd'] == nil then
    conf['cmd'] = set_command()
  end
  if conf['root_dir'] == nil then
    conf['root_dir'] = set_root_dir()
  end
  if conf['capabilities'] == nil then
    conf['capabilities'] = set_default_capabilities()
  end
  local server = correct_server_conf_key()
  require('lspconfig')[server].setup(conf)
end

return M
