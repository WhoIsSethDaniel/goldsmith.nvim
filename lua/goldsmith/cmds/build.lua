local job = require 'goldsmith.job'
local config = require 'goldsmith.config'
local log = require 'goldsmith.log'
local cmds = require 'goldsmith.cmds'

local M = {}

local last = {}

function M.run(bang, args)
  args = args or {}

  local b = vim.api.nvim_get_current_buf()

  local makeprg
  if config.get('gobuild', 'use_makefile') then
    makeprg = vim.api.nvim_buf_get_option(b, 'makeprg')
  end
  if not makeprg then
    makeprg = 'go build'
  end

  if makeprg ~= 'make' then
    args = cmds.process_args(args)
  end

  local cmd = vim.split(vim.fn.expandcmd(makeprg), '%s')
  vim.list_extend(cmd, args)

  local opts
  if bang == '' then
    opts = config.terminal_opts('gobuild', { terminal = true })
  else
    opts = {
      on_exit = function(id, code)
        log.info('Build', string.format('Job finished with code %d', code))
      end,
    }
  end

  opts = vim.tbl_deep_extend('force', opts, { check_for_errors = true })

  last = { cmd, opts }
  job.run(unpack(last))
end

function M.last(args)
  local cmd, opts = unpack(last)
  vim.list_extend(cmd, args or {})
  job.run(cmd, opts)
end

return M
