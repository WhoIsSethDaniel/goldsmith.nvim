local wb = require'goldsmith.winbuf'

local M = {}

function M.run(cmd, opts)
  local job
  if opts['terminal'] then
    local winbuf = wb.create_winbuf(vim.tbl_deep_extend('force', opts, { create = true }))
    local w = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(winbuf.win)
    job = vim.fn.termopen(cmd, opts)
    vim.api.nvim_set_current_win(w)
  else
    job = vim.fn.jobstart(cmd, opts)
  end
  return job
end

return M
