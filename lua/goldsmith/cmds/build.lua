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

  local lines = {}
  local on_event = function(id, data, event)
    if event == 'stdout' or event == 'stderr' then
      if data then
        vim.list_extend(lines, data)
      end
    end

    if event == 'exit' then
      vim.fn.setqflist({}, ' ', {
        title = cmd,
        lines = lines,
        efm = vim.api.nvim_buf_get_option(b, 'errorformat'),
      })
      vim.api.nvim_command 'doautocmd QuickFixCmdPost'
    end
  end

  if bang == '' then
    last = {
      cmd,
      config.terminal_opts 'gobuild',
      {
        terminal = true,
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = on_event,
        on_stderr = on_event,
        on_exit = on_event,
      },
    }
  else
    last = {
      cmd,
      {
        on_exit = function(id, code)
          log.info('Build', string.format('Job finished with code %d', code))
        end,
      },
    }
  end

  job.run(unpack(last))
end

function M.last(args)
  local cmd, opts = unpack(last)
  vim.list_extend(cmd, args or {})
  job.run(cmd, opts)
end

return M
