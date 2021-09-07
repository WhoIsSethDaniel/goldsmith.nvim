local log = require 'goldsmith.log'
local wb = require 'goldsmith.winbuf'

local M = {}

local last_terminal

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
    if last_terminal ~= nil then
      if vim.api.nvim_buf_is_loaded(last_terminal.buf) then
        vim.api.nvim_buf_delete(last_terminal.buf, { force = true })
      end
    end
    local winbuf = wb.create_winbuf(vim.tbl_deep_extend('force', opts, { create = true }))
    last_terminal = winbuf
    local w = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(winbuf.win)
    job = vim.fn.termopen(cmd, vim.tbl_deep_extend('force', {}, opts))
    vim.api.nvim_set_current_win(w)
  else
    job = vim.fn.jobstart(cmd, opts)
  end
  return job
end

return M
