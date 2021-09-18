local ts = require 'goldsmith.treesitter'

local M = {}

local function already_has_comment(line, name)
  while line >= 0 do
    local c = vim.api.nvim_buf_get_lines(0, line - 1, line, true)
    if string.match(c[1], '^%s*//') ~= nil then
      if string.match(c[1], string.format('^%%s*//%%s+%s', name)) ~= nil then
        return true
      end
    else
      return false
    end
    line = line - 1
  end
  return false
end

function M.make_comments(template, all)
  local items = {}
  vim.list_extend(items, ts.get_all_types())
  vim.list_extend(items, ts.get_all_functions())

  local i = 0
  for _, tf in ipairs(items) do
    local ndx = tf.line + i
    local name = string.match(tf.name, '^([^%s]+)')
    local is_public = string.match(name, '^(%u)') and true or false
    if all or is_public then
      if not already_has_comment(ndx, name) then
        vim.api.nvim_buf_set_lines(0, ndx, ndx, true, { string.format('// ' .. template, name) })
        i = i + 1
      end
    end
  end
end

return M
