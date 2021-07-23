local servers = require 'goldsmith.lsp.servers'
local plugins = require 'goldsmith.plugins'

local M = {}

local config_map = {
  gopls = require 'goldsmith.lsp.autoconfig.gopls',
  lint = require 'goldsmith.lsp.autoconfig.nvim-lint',
  ['efm-langserver'] = require 'goldsmith.lsp.autoconfig.efm',
}

function M.init()
  for _, r in pairs(config_map) do
    if r.has_config() then
      r.config()
    end
  end
end

function M.setup(item, cf)
  local name
  local i = plugins.info(item)
  if i == nil then
    for _, sn in pairs(servers.names()) do
      local sni = servers.info(sn)
      if item == sn or item == sni.name or item == sni.lspconfig_name or item == sni.lspinstall_name then
        name = sn
      end
    end
  else
    name = item
  end
  if name == nil then
    vim.api.nvim_err_writeln(string.format('Cannot determine how to configure %s', item))
  end
  config_map[name].setup(cf)
end

return M
