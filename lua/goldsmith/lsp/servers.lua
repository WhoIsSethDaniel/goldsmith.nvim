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
  if plugins.is_installed 'lspconfig' then
    local sname = M.info(server).lspconfig_name
    log.debug(sname, function()
      return 'lspconfig: ' .. vim.inspect(config)
    end)
    -- for now explicitly exclude null-ls from doing this since it no longer wants this to be done
    if sname ~= 'null-ls' then
      require('lspconfig')[sname].setup(config)
    end
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
