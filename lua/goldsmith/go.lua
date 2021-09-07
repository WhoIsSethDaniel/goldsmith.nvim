local log = require 'goldsmith.log'

local M = {}

function M.list(mod, args)
  local cmd = string.format('go list -json %s', args or '.')
  local out
  if mod then
    out = vim.fn.systemlist(cmd)
  else
    out = vim.fn.systemlist(string.format('GO111MODULE=off %s', cmd))
  end
  if vim.v.shell_error ~= 0 then
    return false
  end
  for i, e in ipairs(out) do
    if e == '}' and out[i + 1] == '{' then
      out[i] = '},'
    end
  end
  return true, vim.fn.json_decode('[' .. table.concat(out, '') .. ']')
end

function M.module_path()
  local ok, m = M.list(true, '-m')
  if ok and m[1]['Dir'] ~= nil and m[1]['Path'] ~= nil then
    return m[1].Path
  end
  ok, m = M.list(false)
  if ok and m['ImportPath'] then
    return m.ImportPath
  end
  return
end

function M.env(name)
  local cmd = string.format('go env %s', string.upper(name))
  local out = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    log.error('Go', string.format("Failed to run '%s'", cmd))
    return
  end
  return out[1]
end

return M
