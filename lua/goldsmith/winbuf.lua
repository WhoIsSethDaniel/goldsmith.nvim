local M = {}

local winstash = {}

function M.determine_window(opts)
  local window = opts['window']
  local pos = window['pos']
  local width = window['width']
  local height = window['height']
  local orient = ''
  local n = height
  local place
  local action = opts['create'] and 'new' or 'split'
  if pos == 'right' or pos == 'left' then
    action = opts['create'] and 'vnew' or 'vsplit'
    orient = 'vertical'
    n = width
  end
  if pos == 'right' or pos == 'bottom' then
    place = 'rightbelow'
  elseif pos == 'left' or pos == 'top' then
    place = 'leftabove'
  end
  return { action = action, orient = orient, place = place, n = n }
end

function M.create_winbuf(opts)
  local dim = M.determine_window(opts)

  local lw = vim.api.nvim_get_current_win()

  local reuse = -1
  local ns = opts['reuse']
  if type(ns) == 'number' then
    reuse = ns
  elseif ns ~= nil and winstash[ns] ~= nil then
    if opts['destroy'] == true then
      if vim.api.nvim_buf_is_loaded(winstash[ns]) then
        vim.api.nvim_buf_delete(winstash[ns], { force = true })
      end
    else
      reuse = winstash[ns]
    end
  end

  local title = opts['title']
  local wn = vim.fn.bufwinid(reuse)
  if reuse > 0 and vim.api.nvim_buf_is_loaded(reuse) and wn ~= -1 then
    vim.fn.win_gotoid(wn)
  elseif reuse > 0 and vim.api.nvim_buf_is_loaded(reuse) then
    vim.cmd(string.format('%s %s %d%s', dim.orient, dim.place, dim.n, dim.action))
    vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), reuse)
  else
    if title ~= nil then
      local bnr = vim.fn.bufnr(vim.fn.fnameescape(title))
      if bnr > -1 then
        vim.api.nvim_buf_delete(bnr, { force = true })
      end
    end
    local file = opts['file'] or ''
    vim.cmd(string.format('%s %s %d%s %s', dim.orient, dim.place, dim.n, dim.action, file))
  end

  local w = vim.api.nvim_get_current_win()
  local b = vim.api.nvim_get_current_buf()

  if ns ~= nil then
    winstash[ns] = b
  end

  if title ~= nil then
    vim.api.nvim_buf_set_name(b, opts['title'])
  end

  if not opts['window']['focus'] then
    vim.api.nvim_set_current_win(lw)
  end

  if opts['keymap'] ~= nil then
    M.create_keymaps(b, opts['keymap'])
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

function M.create_keymaps(buf, type)
  local buffer = require 'goldsmith.buffer'
  if type == 'terminal' then
    buffer.set_buffer_map(buf, '', 'close-terminal', nil, { silent = true })
  elseif type == 'testing' then
    buffer.set_buffer_map(buf, '', 'test-close-window', nil, { silent = true })
  end
  buffer.set_buffer_map(buf, '', 'close-any', nil, { silent = true })
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

function M.set_close_keys(b)
  vim.api.nvim_buf_set_keymap(b, '', 'q', '<cmd>close!<cr>', { silent = true, noremap = true })
  vim.api.nvim_buf_set_keymap(b, '', '<Esc>', '<cmd>close!<cr>', { silent = true, noremap = true })
end

function M.close_any_window(extra)
  for _, ns in ipairs { 'test_native', 'job_terminal' } do
    M.close_window(ns)
  end
  if extra then
    vim.cmd [[ cclose ]]
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(w) then
        vim.api.nvim_win_call(w, function()
          vim.cmd [[lclose]]
        end)
      end
    end
  end
end

function M.close_window(ns)
  local b = winstash[ns]
  if b == nil then
    return
  end
  if vim.api.nvim_buf_is_loaded(b) then
    vim.api.nvim_buf_delete(b, { force = true })
  else
    winstash[ns] = nil
  end
end

return M
