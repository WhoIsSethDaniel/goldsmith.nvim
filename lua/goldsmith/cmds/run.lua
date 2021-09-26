local job = require 'goldsmith.job'
local config = require 'goldsmith.config'

local M = {}

function M.run(args)
  args = args or {}
  if #args == 0 then
    args = { '.' }
  end
  local cmd = string.format('go run %s', table.concat(args, ' '))
  job.run(cmd, config.terminal_opts('gorun'))
end

return M
