local log = require 'goldsmith.log'

local M = {}

function M.list(mod, args)
  local cmd = { 'go', 'list', '-json' }
  vim.list_extend(cmd, args or { '.' })

  local out
  if mod then
    out = vim.fn.systemlist(table.concat(cmd, ' '))
  else
    table.insert(cmd, 1, 'GO111MODULE=off')
    out = vim.fn.systemlist(table.concat(cmd, ' '))
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

local function list_files(wd, fields)
  local ok, list = M.list(false, { wd or '.' })
  if not ok then
    return
  end
  local files = {}
  for _, d in ipairs(list) do
    local dir = d['Dir']
    if not dir then
      break
    end
    local lfiles = {}
    for _, field in ipairs(fields) do
      vim.list_extend(lfiles, d[field] or {})
    end
    for _, f in ipairs(lfiles) do
      table.insert(files, string.format('%s/%s', dir, f))
    end
  end
  return files
end

function M.files(wd)
  return list_files(wd, { 'CGoFiles', 'GoFiles', 'XTestGoFiles', 'TestGoFiles' })
end

function M.code_files(wd)
  return list_files(wd, { 'GoFiles', 'CGoFiles' })
end

function M.test_files(wd)
  return list_files(wd, { 'XTestGoFiles', 'TestGoFiles' })
end

function M.module_path()
  local ok, m = M.list(true, { '-m' })
  if ok and m[1]['Dir'] ~= nil and m[1]['Path'] ~= nil then
    return m[1].Path
  end
  ok, m = M.list(false)
  if ok and m[1]['ImportPath'] then
    return m[1].ImportPath
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
