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
    if vim.api.nvim_buf_get_name(b) == fp then
      if vim.api.nvim_buf_is_loaded(b) then
        return b
      else
        vim.api.nvim_buf_delete(b, { force = true })
        return
      end
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

function M.create_test_file_buffer(f)
  local b = M.find_buffer_by_name(f)
  if b == nil then
    b = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(b, 'bufhidden', 'hide')
    vim.api.nvim_buf_call(b, function()
      vim.cmd(string.format('silent! e! %s', f))
    end)
  end
  return b
end

function M.create_debug_buffer()
  local b = vim.api.nvim_create_buf(false, true)
  M.make_buffer_plain(b, nil, { ft = 'goldsmith-debug', bufhidden = 'hide' })
  vim.api.nvim_buf_set_name(b, '[Goldsmith Debug Console]')
  require('goldsmith.buffer').set_buffer_map(b, '', 'toggle-debug-console', '<cmd>hide<cr>', { silent = true })
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
        M.make_buffer_plain(nil, nwb.win)
        return nwb
      end
    end
  end
  require('goldsmith.log').error('Debug', 'Cannot find Debug Console. The buffer may have been destroyed.')
  return nil
end

function M.append_to_buffer(b, output)
  if vim.api.nvim_buf_is_loaded(b) then
    vim.api.nvim_buf_set_option(b, 'modifiable', true)
    vim.api.nvim_buf_set_lines(b, -1, -1, true, output)
    vim.api.nvim_buf_set_option(b, 'modifiable', false)
  end
end

function M.clear_buffer(b)
  vim.api.nvim_buf_set_option(b, 'modifiable', true)
  vim.api.nvim_buf_set_lines(b, 0, -1, false, {})
  vim.api.nvim_buf_set_option(b, 'modifiable', false)
end

-- function M.set_buffer_map(buf, mode, name, act, opts)
function M.setup_follow_buffer(b)
  local set_buffer_map = require('goldsmith.buffer').set_buffer_map
  set_buffer_map(b, 'n', 'start-follow', nil, { silent = true, noremap = true })
  set_buffer_map(b, 'n', 'stop-follow', nil, { silent = true, noremap = true })
  vim.api.nvim_buf_call(b, function()
    M.start_follow_buffer()
  end)
end

function M.stop_follow_buffer()
  local b = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_call(b, function()
    vim.cmd [[
      augroup goldsmith-follow-buffer
      autocmd! *
      augroup END
    ]]
  end)
end

function M.start_follow_buffer()
  local b = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_call(b, function()
    vim.cmd [[
      augroup goldsmith-follow-buffer
      autocmd! *
      autocmd TextChanged <buffer> normal! G
      augroup END
    ]]
  end)
end

function M.make_buffer_plain(b, w, opts)
  if b ~= nil then
    if opts['ft'] ~= nil then
      vim.api.nvim_buf_set_option(b, 'filetype', opts['ft'])
    end
    if opts['bufhidden'] == nil then
      vim.api.nvim_buf_set_option(b, 'bufhidden', 'wipe')
    else
      vim.api.nvim_buf_set_option(b, 'bufhidden', opts['bufhidden'])
    end
    vim.api.nvim_buf_set_option(b, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(b, 'swapfile', false)
    vim.api.nvim_buf_set_option(b, 'buflisted', false)
  end
  if w ~= nil then
    vim.api.nvim_win_set_option(w, 'cursorline', false)
    vim.api.nvim_win_set_option(w, 'cursorcolumn', false)
    vim.api.nvim_win_set_option(w, 'number', false)
    vim.api.nvim_win_set_option(w, 'signcolumn', 'no')
    vim.api.nvim_win_set_option(w, 'relativenumber', false)
  end
end

return M
