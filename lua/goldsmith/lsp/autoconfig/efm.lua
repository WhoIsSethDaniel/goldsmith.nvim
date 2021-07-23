local plugins = require 'goldsmith.plugins'
local servers = require 'goldsmith.lsp.servers'

local M = {
  _config = {},
}

local DEFAULTS = {
  filetypes = { 'go' },
  init_options = {
    documentFormatting = true,
  },
  settings = {
    languages = {
      go = {
        {
          formatCommand = 'golines --max-len=120',
        },
      },
    },
  },
}

function M.has_config()
  if plugins.is_installed 'lspconfig' and servers.is_installed 'efm-langserver' and M._config ~= nil then
    return true
  end
  return false
end

function M.config()
  require('lspconfig')['efm'].setup(M._config)
end

local set_filetypes = function(cf)
  if vim.tbl_contains(cf, 'go') then
    return cf
  end
  local types = vim.tbl_values(cf)
  table.insert(types, 'go')
  return types
end

local set_init_options = function(cf)
  return vim.tbl_deep_extend('keep', DEFAULTS.init_options, cf or {})
end

local set_settings = function(cf)
  return vim.tbl_deep_extend('keep', DEFAULTS.settings, cf or {})
end

function M.setup(cf)
  M._config = cf
  M._config['filetypes'] = set_filetypes(cf['filetypes'])
  M._config['init_options'] = set_init_options(cf['init_options'])
  M._config['settings'] = set_settings(cf['settings'])
end

return M
