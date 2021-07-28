local config = require 'goldsmith.config'
local fs = require 'goldsmith.fs'
local wb = require'goldsmith.winbuf'

local M = {}

function M.run()
  local cmd_cfg = config.get 'goalt' or {}
  local window_cfg = config.get 'window'
  local alt = fs.alternate_file_name(vim.fn.expand '%')

  local win = wb.find_window_by_name(alt)
  if win ~= nil then
    vim.fn.win_gotoid(win)
  else
    wb.create_winbuf(vim.tbl_deep_extend('force', window_cfg, cmd_cfg, { file = alt }))
  end
end

return M
