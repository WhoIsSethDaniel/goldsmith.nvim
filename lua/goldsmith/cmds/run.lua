local job = require 'goldsmith.job'
local config = require 'goldsmith.config'

local M = {}

function M.run(args)
  local cmd_cfg = config.get 'gorun' or {}
  local terminal_cfg = config.get 'terminal'
  if #args == 0 then
    args = { '.' }
  end
  local cmd = string.format('go run %s', table.concat(args, ' '))
  job.run(cmd, vim.tbl_deep_extend('force', terminal_cfg, cmd_cfg, { terminal = true }))
end

return M
