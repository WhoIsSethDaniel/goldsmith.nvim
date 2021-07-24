local job = require 'goldsmith.job'
local config = require 'goldsmith.config'

local M = {}

function M.run(...)
  local cmd_cfg = config.get 'gorun' or {}
  local terminal_cfg = config.get 'terminal'
  local args = ''
  for _, a in ipairs { ... } do
    args = string.format('%s %s', args, a)
  end
  local cmd = string.format('go run %s', args)
  job.run(cmd, vim.tbl_deep_extend('force', terminal_cfg, cmd_cfg, { terminal = true }))
end

return M
