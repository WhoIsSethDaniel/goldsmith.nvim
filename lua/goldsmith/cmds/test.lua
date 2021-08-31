local fs = require 'goldsmith.fs'
local config = require 'goldsmith.config'
local job = require 'goldsmith.job'
local log = require 'goldsmith.log'

local M = {}

function M.run(bang, args)
  local cf = vim.fn.expand '%'
  if #args == 0 then
    table.insert(args, fs.relative_to_cwd(cf))
  end
  local cmd = vim.list_extend({ 'go', 'test' }, args)
  local opts = {}
  if bang == '' then
    opts = config.terminal_opts('testing', { title = table.concat(cmd, ' ') })
  end
  job.run(cmd, opts, {
    on_exit = function()
      log.info('Testing', string.format("'%s': command finished", table.concat(cmd, ' ')))
    end,
  })
end

return M
