local tools = require 'goldsmith.tools'
local plugins = require 'goldsmith.plugins'
local log = require 'goldsmith.log'

local M = {}

function M.check()
  local names = M.names()
  return tools.check(names)
end

function M.is_server(name)
  for _, sn in pairs(M.names()) do
    local sni = M.info(sn)
    for _, pn in ipairs { sn, sni.lspconfig_name, sni.lspinstall_name, sni.exe } do
      if name == pn then
        return true, sn
      end
    end
  end
  return false
end

function M.run_setup_function(server, config)
  if plugins.is_installed 'lspinstaller' then
    local installed = vim.tbl_map(function(v)
      return v.name
    end, require('nvim-lsp-installer').get_installed_servers())
    local sname = M.info(server).lspconfig_name
    if vim.tbl_contains(installed, sname) then
      log.debug(sname, function()
        return 'lsp-installer: ' .. vim.inspect(config)
      end)
      local ok, svr = require('nvim-lsp-installer').get_server(sname)
      svr:setup(config)
      return true
    end
  end

  if plugins.is_installed 'lspconfig' then
    local sname = M.info(server).lspconfig_name
    log.debug(sname, function()
      return 'lspconfig: ' .. vim.inspect(config)
    end)
    require('lspconfig')[sname].setup(config)
    return true
  end

  log.error('Config', string.format("Failed to setup server '%s'.", server))
  return false
end

function M.names()
  return tools.names { server = true }
end

M.is_required = tools.is_required
M.is_installed = tools.is_installed
M.info = tools.info
M.dump = tools.dump

return M
