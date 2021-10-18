local config = require 'goldsmith.config'
local job = require 'goldsmith.job'
local log = require 'goldsmith.log'
local cmds = require 'goldsmith.cmds'

local M = {}

function M.run(bang, args)
  args = cmds.process_args(args)

  local cmd = vim.list_extend({ 'go', 'test' }, args)
  local opts = {}
  if bang == '' then
    opts = config.window_opts('gotest', { title = table.concat(cmd, ' ') })
  end

  job.run(cmd, opts, {
    on_exit = function(id, code)
      log.info('Testing', string.format("Command '%s' finished with code %d", table.concat(cmd, ' '), code))
    end,
  })
end

return M
