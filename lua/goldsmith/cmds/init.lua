local fs = require 'goldsmith.fs'

local M = {}

function M.process_args(args)
  args = args or {}
  local current_pkg = fs.relative_to_cwd(vim.fn.expand '%')
  local has_file_arg = false
  for i, arg in ipairs(args) do
    local before = args[i]
    args[i] = vim.fn.expand(arg)
    if before ~= args[i] then
      has_file_arg = true
    elseif arg == '--' then
      args[i] = current_pkg
      has_file_arg = true
    elseif arg == '...' then
      args[i] = current_pkg .. '/...'
      has_file_arg = true
    elseif fs.is_valid_package(arg) then
      has_file_arg = true
    end
  end
  if not has_file_arg then
    table.insert(args, current_pkg)
  end
  return args
end

return M
