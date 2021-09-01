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
  local cp = fs.relative_to_cwd(vim.fn.expand '%')
  local list = go.list(cp)
  local test_files = list[1]['TestGoFiles'] or {}
  local dir = list[1]['Dir']
  local tests = {}
  for _, tf in ipairs(test_files) do
    local fp = dir .. '/' .. tf
    local f, err = io.open(dir .. '/' .. tf)
    if f == nil then
      log.warn('Testing', string.format("Cannot open file '%s' for reading: %s", fp, err))
    else
      for line in f:lines() do
        local fname = string.match(line, 'func%s+(Test.*)%(')
        table.insert(tests, fname)
      end
    end
  end
  table.sort(tests)
  return table.concat(tests, '\n')
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
