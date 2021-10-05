local job = require 'goldsmith.job'
local config = require 'goldsmith.config'
local log = require 'goldsmith.log'
local cmds = require 'goldsmith.cmds'

local M = {}

local last = {}

function M.run(bang, args)
  args = cmds.process_args(args)

  local cmd = { 'go', 'run' }
  vim.list_extend(cmd, args)

  if bang == '' then
    last = { cmd, config.terminal_opts 'gorun' }
  else
    last = { cmd, {
      on_exit = function(id, code)
        log.info('Run', string.format('Job finished with code %d', code))
      end,
    } }
  end
  job.run(unpack(last))
end

function M.last(args)
  local cmd, opts = unpack(last)
  vim.list_extend(cmd, args or {})
  job.run(cmd, opts)
end

return M
