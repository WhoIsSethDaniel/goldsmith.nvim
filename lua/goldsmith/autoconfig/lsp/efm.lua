local plugins = require 'goldsmith.plugins'
local servers = require 'goldsmith.lsp.servers'
local _config = require 'goldsmith.config'

local M = {
  _config = {},
}

local function set_command()
  return { servers.info('efm').cmd }
end

local function set_filetypes(cf)
  if vim.tbl_contains(cf, 'go') then
    return cf
  end
  table.insert(cf, 'go')
  return cf
end

local function set_init_options(cf)
  cf['documentFormatting'] = true
  return cf
end

local function set_settings(conf, settings)
  local new = vim.tbl_deep_extend('keep', settings, { languages = { go = {} } })
  table.insert(new.languages.go, { formatCommand = string.format("golines --max-len=%d", conf['max_line_length']) })
  return new
end

function M.has_config()
  if plugins.is_installed 'lspconfig' and servers.is_installed 'efm' and M._config ~= nil then
    return true
  end
  return false
end

function M.config()
  local formatcf = _config.get('format')
  if M._config['cmd'] == nil then
    M._config['cmd'] = set_command()
  end
  M._config['filetypes'] = set_filetypes(M._config['filetypes'] or {})
  M._config['init_options'] = set_init_options(M._config['init_options'] or {})
  M._config['settings'] = set_settings(formatcf, M._config['settings'] or {})
  require('lspconfig')['efm'].setup(M._config)
end

function M.setup(cf)
  M._config = cf
end

return M
