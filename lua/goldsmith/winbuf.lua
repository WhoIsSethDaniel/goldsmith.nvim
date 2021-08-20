local M = {}

function M.determine_window(opts)
  local pos = opts['pos']
  local width = opts['width']
  local height = opts['height']
  local orient = ''
  local n = height
  local place
  if pos == 'right' or pos == 'left' then
    orient = 'vertical'
    n = width
  end
  if pos == 'right' or pos == 'bottom' then
    place = 'rightbelow'
  elseif pos == 'left' or pos == 'top' then
    place = 'leftabove'
  end
  return { orient = orient, place = place, n = n }
end

function M.create_winbuf(opts)
  local dim = M.determine_window(opts)

  local lw = vim.api.nvim_get_current_win()

  local action = 'split'
  if opts['create'] then
    action = 'new'
  end

  local reuse = opts['reuse'] or -1
  local wn = vim.fn.bufwinid(reuse)
  if reuse > 0 and vim.api.nvim_buf_is_loaded(reuse) and wn ~= -1 then
    vim.fn.win_gotoid(wn)
  elseif reuse > 0 and vim.api.nvim_buf_is_loaded(reuse) then
    vim.cmd(string.format('%s %s %d%s', dim.orient, dim.place, dim.n, action))
    vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), reuse)
  else
    local file = opts['file'] or ''
    vim.cmd(string.format('%s %s %d%s %s', dim.orient, dim.place, dim.n, action, file))
  end

  local w = vim.api.nvim_get_current_win()
  local b = vim.api.nvim_get_current_buf()

  if opts['title'] ~= nil then
    vim.api.nvim_buf_set_name(b, opts['title'])
  end

  if opts['focus'] == false then
    vim.api.nvim_set_current_win(lw)
  end

  return { win = w, buf = b }
end

function M.find_buffer_by_name(name)
  local fp = vim.fn.fnamemodify(name, ':p')
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_name(b) == fp then
      return b
    end
  end
end

function M.find_window_by_name(name)
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

function M.create_debug_buffer()
  local b = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(b, 'filetype', 'goldsmith-debug')
  vim.api.nvim_buf_set_option(b, 'bufhidden', 'hide')
  vim.api.nvim_buf_set_option(b, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(b, 'swapfile', false)
  vim.api.nvim_buf_set_option(b, 'buflisted', false)
  vim.api.nvim_buf_set_option(b, 'modifiable', false)
  vim.api.nvim_buf_set_name(b, '[Goldsmith Debug Console]')
  return { buf = b, win = -1 }
end

function M.toggle_debug_console(wb, opts)
  if wb ~= nil then
    if wb.win >= 0 and vim.api.nvim_win_is_valid(wb.win) then
      vim.api.nvim_win_hide(wb.win)
      wb.win = -1
      return wb
    else
      if vim.api.nvim_buf_is_loaded(wb.buf) then
        local nwb = M.create_winbuf(vim.tbl_deep_extend('force', opts, { reuse = wb.buf }))
        vim.api.nvim_win_set_option(nwb.win, 'cursorline', false)
        vim.api.nvim_win_set_option(nwb.win, 'cursorcolumn', false)
        vim.api.nvim_win_set_option(nwb.win, 'number', false)
        vim.api.nvim_win_set_option(nwb.win, 'relativenumber', false)
        vim.api.nvim_win_set_option(nwb.win, 'signcolumn', 'no')
        return nwb
      end
    end
  end
  require('goldsmith.log').error('Debug', 'Cannot find Debug Console. The buffer may have been destroyed.')
  return nil
end

return M
