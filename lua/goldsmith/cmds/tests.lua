local job = require 'goldsmith.job'
local config = require 'goldsmith.config'
local ts = require 'goldsmith.treesitter'
local fs = require 'goldsmith.fs'
local log = require 'goldsmith.log'

local M = {}

function M.complete(arglead, cmdline, cursorPos)
  local funcs = ts.get_all_functions()
  local current = ts.get_current_function_name()
  if current ~= nil then
    for i, f in ipairs(funcs) do
      if f.name == current then
        table.remove(funcs, i)
        table.insert(funcs, f)
        break
      end
    end
  end
  local f = {}
  for _, fd in ipairs(funcs) do
    table.insert(f, fd.name)
  end
  return table.concat(f, '\n')
end

local function parse_args(args)
  local f
  local opt = ''
  for i, a in ipairs(args) do
    if a == '-p' or a == '-e' then
      if opt ~= '' then
        log.error('Tests', '-p and -e may not be used together')
        return
      end
      if a == '-p' then
        opt = '-parallel'
      else
        opt = '-exported'
      end
    else
      if i ~= #args then
        log.error('Tests', 'too many arguments to :GoAddTest')
        return
      else
        f = a
        break
      end
    end
  end
  return opt, f
end

function M.add(args)
  local opt, f = parse_args(args)
  if opt == nil then
    return
  end
  if f == nil then
    local func = ts.get_current_function_name()
    if func == nil then
      log.error('Tests', 'Cannot determine test to add. Please provide a test name.')
    end
    M.run(opt, '-only', func)
  else
    M.run(opt, '-only', f)
  end
end

function M.generate(option)
  local opt = parse_args(option)
  if opt == nil then
    return
  end
  M.run(opt or '', '-all')
end

function M.run(...)
  local args = ''
  for _, a in ipairs { ... } do
    args = string.format('%s %s', args, a)
  end
  local fp = vim.fn.expand '%'
  if vim.fn.isdirectory(fp) > 0 then
    log.error('Tests', 'Current file is a directory')
    return
  end
  if fs.is_test_file(fp) then
    log.error('Tests', 'Current file is a test file')
    return
  end
  local extra = config.get 'testing' or {}
  if extra['template'] ~= nil and extra['template'] ~= '' then
    args = string.format('%s -template %s', args, extra['template'])
  end
  if extra['template_dir'] ~= nil and extra['template_dir'] ~= '' then
    args = string.format('%s -template_dir %s', args, extra['template_dir'])
  end
  if extra['template_params_file'] ~= nil and extra['template_params_file'] ~= '' then
    args = string.format('%s -template_params_file %s', args, extra['template_params_file'])
  end
  local cmd = vim.split(string.format('gotests -w %s %s', args, fp), ' ')
  local ok = false
  local out = ''
  job.run(cmd, {
    stdout_buffered = true,
    on_stdout = function(jobid, data, name)
      for _, s in ipairs(data) do
        if string.match(s, '^Generated') ~= nil then
          ok = true
        elseif s ~= '' then
          out = data[1]
          break
        end
      end
    end,
    on_exit = function(jobid, code, event)
      if ok then
        log.info('Tests', 'Test(s) generated.')
      else
        log.error('Tests', string.format('Failed to generate tests. %s (code %d)', vim.inspect(out), code))
      end
    end,
  })
end

return M
