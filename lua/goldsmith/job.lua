local log = require 'goldsmith.log'
local wb = require 'goldsmith.winbuf'

local M = {}

local running_jobs = {}

function M.run(cmd, ...)
  local opts = vim.tbl_deep_extend('force', {}, ...)

  log.debug('Job', function()
    return 'cmd: ' .. vim.inspect(cmd)
  end)
  log.debug('Job', function()
    return 'opts: ' .. vim.inspect(opts)
  end)
  local job
  if opts['terminal'] then
    local winbuf = wb.create_winbuf(
      vim.tbl_deep_extend('force', opts, { reuse = 'job_terminal', destroy = true, keymap = 'terminal', create = true })
    )
    local w = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(winbuf.win)
    job = vim.fn.termopen(cmd, vim.tbl_deep_extend('force', {}, opts))
    vim.api.nvim_set_current_win(w)
  else
    local exit = opts['on_exit']
    opts['on_exit'] = function(id, code, type)
      running_jobs[id] = nil
      if exit ~= nil then
        exit(id, code, type)
      end
    end
    job = vim.fn.jobstart(cmd, opts)
    running_jobs[job] = cmd
  end
  return job
end

function M.running_jobs()
  return running_jobs
end

return M
