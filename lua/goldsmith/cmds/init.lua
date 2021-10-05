local fs = require 'goldsmith.fs'

local M = {}

function M.process_args(args)
  args = args or {}
  local has_file_arg = false
  for i, arg in ipairs(args) do
    if arg == '--' then
      table.remove(args, i)
      table.insert(args, i, fs.relative_to_cwd(vim.fn.expand '%'))
      has_file_arg = true
      break
    end
    if fs.is_valid_package(arg) then
      has_file_arg = true
      break
    end
  end
  if not has_file_arg then
    table.insert(args, fs.relative_to_cwd(vim.fn.expand '%'))
  end
  return args
end

return M
