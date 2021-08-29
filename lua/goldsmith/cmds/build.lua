local job = require 'goldsmith.job'
local config = require 'goldsmith.config'

local M = {}

function M.run(args)
  local cmd_cfg = config.get 'gobuild' or {}
  local terminal_cfg = config.get 'terminal'

  local b = vim.api.nvim_get_current_buf()

  local makeprg = vim.api.nvim_buf_get_option(b, 'makeprg')
  if not makeprg then
    return
  end

  local cmd = vim.fn.expandcmd(string.format("%s %s", makeprg, table.concat(args, ' ')))

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

  job.run(
    cmd,
    vim.tbl_deep_extend('force', terminal_cfg, cmd_cfg, {
      terminal = true,
      stdout_buffered = true,
      stderr_buffered = true,
      on_stdout = on_event,
      on_stderr = on_event,
      on_exit = on_event,
    })
  )
end

return M
