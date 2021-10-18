local job = require 'goldsmith.job'
local config = require 'goldsmith.config'

local M = {}

function M.run(args)
  for i, arg in ipairs(args) do
    local m = string.match(arg, '^https?://(.*)$') or arg
    table.remove(args, i)
    table.insert(args, i, m)
  end
  local cmd = { 'go', 'get'}
  vim.list_extend(cmd, args)
  job.run(cmd, config.window_opts 'goget')
end

return M
