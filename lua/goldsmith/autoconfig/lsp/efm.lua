local plugins = require 'goldsmith.plugins'
local servers = require 'goldsmith.lsp.servers'
local config = require 'goldsmith.config'

local M = {
  _config = {},
}

function M.has_config()
  if plugins.is_installed 'lspconfig' and servers.is_installed 'efm' and M._config ~= nil then
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
  table.insert(cf, 'go')
  return cf
end

local set_init_options = function(cf)
  cf['documentFormatting'] = true
  return cf
end

local set_settings = function(conf, settings)
  local new = vim.tbl_deep_extend('keep', settings, { languages = { go = {} } })
  table.insert(new.languages.go, { formatCommand = string.format("golines --max-len=%d", conf['max_line_length']) })
  return new
end

function M.setup(cf)
  local formatcf = config.get('format')
  M._config = cf
  M._config['filetypes'] = set_filetypes(cf['filetypes'] or {})
  M._config['init_options'] = set_init_options(cf['init_options'] or {})
  M._config['settings'] = set_settings(formatcf, cf['settings'] or {})
end

return M
