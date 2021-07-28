local config = require 'goldsmith.config'
local fs = require 'goldsmith.fs'

local M = {}

local create_new_buffer = function(opts)
  local pos = opts['pos'] or 'right'
  local width = opts['width'] or 80
  local height = opts['height'] or 20
  local orient
  local place
  local n
  if pos == 'right' or pos == 'left' then
    orient = 'vertical'
    n = width
  elseif pos == 'bottom' or pos == 'top' then
    orient = 'horizontal'
    n = height
  end
  if pos == 'right' or pos == 'bottom' then
    place = 'rightbelow'
  elseif pos == 'left' or pos == 'top' then
    place = 'leftabove'
  end
  if opts['file'] == nil then
    vim.cmd(string.format('%s %s %dsplit', orient, place, n))
  else
    vim.cmd(string.format('%s %s %dsplit %s', orient, place, n, opts['file']))
  end
end

local find_buffer = function(name)
  local fp = vim.fn.fnamemodify(name, ':p')
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_name(b) == fp then
      return b
    end
  end
end

local find_window = function(name)
  local fp = vim.fn.fnamemodify(name, ':p')
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(w) then
      local b = vim.api.nvim_win_get_buf(w)
      if vim.api.nvim_buf_get_name(b) == fp then
        return w
      end
    end
  end
end

function M.run()
  local cmd_cfg = config.get 'goalt' or {}
  local terminal_cfg = config.get 'terminal'
  local alt = fs.alternate_file_name(vim.fn.expand '%')

  local win = find_window(alt)
  if win ~= nil then
    vim.fn.win_gotoid(win)
  else
    local buf = find_buffer(alt)
    if buf ~= nil then
      create_new_buffer(vim.tbl_deep_extend('force', terminal_cfg, cmd_cfg, { file = alt }))
    else
      create_new_buffer(vim.tbl_deep_extend('force', terminal_cfg, cmd_cfg))
      vim.cmd(string.format(':silent! e! %s', alt))
    end
  end
end

return M
