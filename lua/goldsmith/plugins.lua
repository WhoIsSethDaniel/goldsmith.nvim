local tools = require 'goldsmith.tools'

local M = {}

function M.names()
  return tools.names { plugin = true }
end

function M.check()
  local names = M.names()
  return tools.check(names)
end

function M.is_required(plugin)
  return tools.is_required(plugin)
end

function M.is_installed(plugin)
  return tools.is_installed(plugin)
end

function M.info(plugin)
  return tools.info(plugin)
end

function M.dump()
  tools.dump()
end

return M
