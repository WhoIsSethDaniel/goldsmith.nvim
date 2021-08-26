local tools = require 'goldsmith.tools'
local wb = require 'goldsmith.winbuf'
local fs = require 'goldsmith.fs'
local ts = require 'goldsmith.treesitter'
local go = require 'goldsmith.go'

local M = {}

local default_testing_mod = 'basic'

goldsmith_test_complete = function()
  return M.test_complete()
end

goldsmith_test_package_complete = function()
  return M.package_complete()
end

function M.package_complete()
  local l = go.list './...'
  local pkgs = {}
  for _, p in ipairs(l) do
    local d = vim.fn.fnamemodify(p.Dir, ':.')
    if d ~= vim.fn.getcwd() then
      table.insert(pkgs, './'..d)
    end
  end
  table.sort(pkgs)
  table.insert(pkgs, './...')
  table.insert(pkgs, '.')
  return table.concat(pkgs, '\n')
end

function M.test_complete()
  local cf = vim.fn.expand '%'
  local tf = cf
  if fs.is_code_file(cf) then
    tf = fs.test_file_name(cf)
  end
  local b = wb.create_test_file_buffer(tf)
  local tests = vim.api.nvim_buf_call(b, function()
    return ts.get_all_functions()
  end)
  local n = {}
  for _, t in ipairs(tests) do
    if string.match(t.name, '^Test') ~= nil then
      table.insert(n, t.name)
    end
  end
  return table.concat(n, '\n')
end

function M.setup()
  if M['testing_module'] ~= nil then
    return
  end

  local testing_plugins = tools.names { testing = true }
  table.sort(testing_plugins, function(a, b)
    return tools.info(a).weight > tools.info(b).weight
  end)

  local mod_name = default_testing_mod
  for _, tp in ipairs(testing_plugins) do
    if tools.is_installed(tp) then
      mod_name = tools.info(tp).name
      break
    end
  end

  local m = require(string.format('goldsmith.testing.%s', mod_name))
  M.testing_module = function()
    return m
  end
  m.create_commands()
end

return M
