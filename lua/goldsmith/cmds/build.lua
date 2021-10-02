local job = require 'goldsmith.job'
local config = require 'goldsmith.config'

local M = {}

local last = {}

function M.run(args)
  args = args or {}
  if #args == 0 then
    table.insert(args, vim.fn.fnamemodify(vim.fn.expand '%', ':p:h'))
  end
  local b = vim.api.nvim_get_current_buf()

  local makeprg = vim.api.nvim_buf_get_option(b, 'makeprg')
  if not makeprg then
    return
  end

  local cmd = vim.split(vim.fn.expandcmd(string.format('%s %s', makeprg, table.concat(args, ' '))), '%s')

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
  job.run(unpack(last))
end

function M.last(args)
  local cmd, opts = unpack(last)
  vim.list_extend(cmd, args or {})
  job.run(cmd, opts)
end

return M
