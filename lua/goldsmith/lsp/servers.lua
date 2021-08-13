local tools = require 'goldsmith.tools'
local plugins = require 'goldsmith.plugins'

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

function M.lsp_plugin_name(server)
  if plugins.is_installed 'lspinstall' then
    return M.info(server).lspinstall_name
  elseif plugins.is_installed 'lspconfig' then
    return M.info(server).lspconfig_name
  end
end

function M.names()
  return tools.names { server = true }
end

M.is_required = tools.is_required
M.is_installed = tools.is_installed
M.info = tools.info
M.dump = tools.dump

return M
