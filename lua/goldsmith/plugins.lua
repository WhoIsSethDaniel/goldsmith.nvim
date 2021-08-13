local tools = require 'goldsmith.tools'

local M = {}

function M.names()
  return tools.names { plugin = true }
end

function M.check()
  local names = M.names()
  return tools.check(names)
end

M.is_required = tools.is_required
M.is_installed = tools.is_installed
M.info = tools.info
M.dump = tools.dump

return M
