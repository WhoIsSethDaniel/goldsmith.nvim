local job = require 'goldsmith.job'
local config = require 'goldsmith.config'

local M = {}

function M.run(args)
  local cmd = string.format('go get %s', table.concat(args, ' '))
  job.run(cmd, config.terminal_opts('goget'))
end

return M
