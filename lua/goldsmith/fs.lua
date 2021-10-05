local M = {}

function M.has_test_file_name(name)
  return string.match(name, '^.+_test%.go$') ~= nil
end

function M.has_code_file_name(name)
  return string.match(name, '^.+%.go$') ~= nil and not M.has_test_file_name(name)
end

function M.is_test_file(name)
  local type = vim.fn.getftype(name)
  if M.has_test_file_name(name) and (type == 'link' or type == 'file') then
    return true
  end
  return false
end

function M.is_code_file(name)
  return not M.is_test_file(name)
end

function M.test_file_name(name)
  if M.has_test_file_name(name) then
    return name
  end
  if M.has_code_file_name(name) then
    local m = string.match(name, '^(.*)%.go$')
    return string.format('%s_test.go', m)
  end
end

function M.code_file_name(name)
  if M.has_code_file_name(name) then
    return name
  end
  if M.has_test_file_name(name) then
    local m = string.match(name, '^(.*)_test%.go$')
    return string.format('%s.go', m)
  end
end

function M.alternate_file_name(name)
  if M.has_code_file_name(name) then
    return M.test_file_name(name)
  end
  if M.has_test_file_name(name) then
    return M.code_file_name(name)
  end
end

function M.relative_to_cwd(name)
  local rel = vim.fn.isdirectory(name) == 0 and vim.fn.fnamemodify(name, ':h:.') or vim.fn.fnamemodify(name, ':.')
  if rel == '.' then
    return '.'
  else
    return './' .. rel
  end
end

function M.is_valid_package(name)
  return vim.fn.filereadable(name) > 0 or vim.fn.isdirectory(name) > 0 or string.match(name, '^.+/%.%.%.$') ~= nil
end


return M
