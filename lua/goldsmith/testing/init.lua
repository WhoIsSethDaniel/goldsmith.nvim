local wb = require 'goldsmith.winbuf'
local fs = require 'goldsmith.fs'
local ts = require 'goldsmith.treesitter'
local go = require 'goldsmith.go'
local config = require 'goldsmith.config'
local log = require 'goldsmith.log'

local M = {}

goldsmith_test_complete = function()
  return M.test_complete()
end

goldsmith_test_package_complete = function()
  return M.package_complete()
end

function M.testing_strategy()
  local strategy = config.get('testing', 'strategy')
  local runner = config.get('testing', 'runner')
  if runner == 'native' then
    if not vim.tbl_contains( config.native_testing_strategies(), strategy) then
      return config.native_testing_default_strategy()
    end
  elseif runner == 'vim-test' then
    if vim.tbl_contains( config.native_testing_strategies(), strategy) then
      return config.vim_test_default_strategy()
    end
  end
  return strategy
end

function M.package_complete()
  local l = go.list './...'
  local pkgs = {}
  for _, p in ipairs(l) do
    local d = vim.fn.fnamemodify(p.Dir, ':.')
    if d ~= vim.fn.getcwd() then
      table.insert(pkgs, './' .. d)
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

  local mod_name = config.get('testing', 'runner')
  local m = require(string.format('goldsmith.testing.%s', mod_name))
  if not m.has_requirements() then
    log.warn('Testing', string.format("Requirements for %s are not met. Setting testing to 'native'.", mod_name))
    mod_name = 'native'
    m = require(string.format('goldsmith.testing.%s', mod_name))
  end
  M.testing_module = function()
    return m
  end
  m.create_commands()
end

return M
