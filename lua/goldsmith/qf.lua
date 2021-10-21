local M = {}

local function sort(list)
  table.sort(list, function(a, b)
    if a.filename == b.filename then
      return a.lnum < b.lnum
    end
    return a.filename < b.filename
  end)

  -- unique-ify
  local prev
  return vim.tbl_filter(function(e)
    if prev == nil then
      prev = e
      return true
    end
    if prev.filename == e.filename and prev.lnum == e.lnum and prev.text == e.text then
      prev = e
      return false
    end
    prev = e
    return true
  end, list)
end

-- opts:
-- empty: boolean: true: allow empty list
--                 false: do not allow empty list
-- sort: boolean: true: sort and unique the given list; false: don't
-- type: 'local' or 'qf' (assumed 'qf'): local or quickfix
-- focus: boolean: true: focus the quickfix
--                 false: focus current window
-- win: number: pass in window number to focus (if focus = false)
function M.open(list, opts)
  if not opts['empty'] and #list == 0 then
    return
  end
  -- local w = opts['win'] or vim.api.nvim_get_current_win()
  local w = opts['win'] or vim.api.nvim_get_current_win()
  if opts['sort'] then
    list = sort(list)
  end
  local title = opts['title'] or ''
  if opts['type'] == 'local' then
    vim.fn.setloclist(w, {}, ' ', { nr = '$', items = list, title = title })
    vim.cmd [[lopen]]
  else
    vim.fn.setqflist({}, ' ', { nr = '$', items = list, title = title })
    vim.cmd [[copen]]
  end
  if not opts['focus'] then
    vim.api.nvim_set_current_win(w)
  end
  vim.api.nvim_command 'doautocmd QuickFixCmdPost'
end

return M
