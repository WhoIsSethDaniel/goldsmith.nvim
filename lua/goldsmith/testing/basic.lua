local job = require 'goldsmith.job'
local config = require 'goldsmith.config'

local M = {}

function M.run(...)
  local args = {...}
  local cmd = vim.list_extend({ 'go', 'test' }, vim.tbl_deep_extend('force', config.get('testing', 'arguments'), args))
  job.run(cmd, vim.tbl_deep_extend('force', config.get 'gotest' or {}, config.get 'terminal', { terminal = true }))
end

function M.create_commands()
  vim.cmd [[
    command! -nargs=* -bar GoTest lua require'goldsmith.testing.basic'.run(<f-args>)
  ]]
end

return M
