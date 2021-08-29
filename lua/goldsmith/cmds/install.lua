local job = require 'goldsmith.job'
local config = require 'goldsmith.config'

local M = {}

function M.run(args)
  local cmd_cfg = config.get 'goinstall' or {}
  local terminal_cfg = config.get 'terminal'
  local cmd = string.format('go install %s', table.concat(args, ' '))
  job.run(cmd, vim.tbl_deep_extend('force', terminal_cfg, cmd_cfg, { terminal = true }))
end

return M
