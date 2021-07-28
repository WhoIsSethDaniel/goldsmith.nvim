local M = {}

function M.blah()
  if M.buf_nr == -1 then
    vim.cmd(open_new)
    M.buf_nr = api.nvim_get_current_buf()
    api.nvim_buf_set_name(M.buf_nr, '[Go Documentation]')
  elseif vim.fn.bufwinnr(M.buf_nr) == -1 then
    vim.cmd(open_split)
    api.nvim_win_set_buf(0, M.buf_nr)
  elseif vim.fn.bufwinnr(M.buf_nr) ~= vim.fn.bufwinnr '%' then
    vim.cmd(vim.fn.bufwinnr(M.buf_nr) .. 'wincmd w')
  end
end

function M.determine_window(opts)
  local pos = opts['pos'] or 'right'
  local width = opts['width'] or 80
  local height = opts['height'] or 20
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

return M
