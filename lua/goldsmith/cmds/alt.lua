local config = require 'goldsmith.config'
local fs = require 'goldsmith.fs'
local wb = require 'goldsmith.winbuf'

local M = {}

function M.run(create)
  local cmd_cfg = config.get 'goalt' or {}
  local window_cfg = config.get 'window'
  local alt = vim.fn.fnamemodify(fs.alternate_file_name(vim.fn.expand '%'), ':p')

  if vim.fn.getftype(alt) == '' and create == '' then
    vim.api.nvim_err_writeln(string.format('GoAlt: %s: file does not exist', alt))
    return
  end

  vim.cmd[[ silent! wall! ]]

  if cmd_cfg['use_current_window'] then
    vim.cmd(string.format('silent! e! %s', alt))
    vim.cmd[[ silent! w! ]]
    return
  end

  local win = wb.find_window_by_name(alt)
  if win ~= nil then
    vim.fn.win_gotoid(win)
  else
    local b = wb.create_winbuf(vim.tbl_deep_extend('force', window_cfg, cmd_cfg, { file = alt }))
    vim.api.nvim_buf_call(b.buf, function() vim.cmd[[ silent! w! ]] end)
  end
end

return M
