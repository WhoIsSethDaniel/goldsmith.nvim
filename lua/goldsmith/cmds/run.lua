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

  local opts
  if bang == '' then
    opts = config.window_opts 'gorun'
  else
    opts = {
      on_exit = function(id, code)
        log.info('Run', string.format('Job finished with code %d', code))
      end,
    }
  end

  opts = vim.tbl_extend('force', opts, { check_for_errors = true })

  last = { cmd, opts }
  job.run(unpack(last))
end

function M.last(args)
  local cmd, opts = unpack(last)
  vim.list_extend(cmd, args or {})
  job.run(cmd, opts)
end

return M
