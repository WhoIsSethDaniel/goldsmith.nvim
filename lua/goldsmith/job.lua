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
  vim.cmd(string.format('%s %s %dnew', orient, place, n))
end

function M.run(cmd, opts)
  local job
  if opts['terminal'] then
    local win = vim.api.nvim_get_current_win()
    create_new_buffer(opts)
    job = vim.fn.termopen(cmd, opts)
    if opts['focus'] == false then
      vim.api.nvim_set_current_win(win)
    end
  else
    job = vim.fn.jobstart(cmd, opts)
  end
  return job
end

return M
