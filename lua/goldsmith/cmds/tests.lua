local job = require 'goldsmith.job'
local config = require 'goldsmith.config'
local ts = require 'goldsmith.treesitter'
local fs = require 'goldsmith.fs'

local M = {}

-- Usage of gotests:
--   -all
--     	generate tests for all functions and methods
--   -excl string
--     	regexp. generate tests for functions and methods that don't match. Takes precedence over -only, -exported, and -all
--   -exported
--     	generate tests for exported functions and methods. Takes precedence over -only and -all
--   -i	print test inputs in error messages
--   -nosubtests
--     	disable generating tests using the Go 1.7 subtests feature
--   -only string
--     	regexp. generate tests for functions and methods that match only. Takes precedence over -all
--   -parallel
--     	enable generating parallel subtests
--   -template string
--     	optional. Specify custom test code templates, e.g. testify. This can also be set via environment variable GOTESTS_TEMPLATE
--   -template_dir string
--     	optional. Path to a directory containing custom test code templates. Takes precedence over -template. This can also be set via environment variable GOTESTS_TEMPLATE_DIR
--   -template_params string
--     	read external parameters to template by json with stdin
--   -template_params_file string
--     	read external parameters to template by json with file
--   -w	write output to (test) files instead of stdout

function M.complete(arglead, cmdline, cursorPos)
  local funcs = ts.get_all_functions()
  local current = ts.get_current_function_name()
  if current ~= nil then
    for i, f in ipairs(funcs) do
      if f == current then
        table.remove(funcs, i)
        table.insert(funcs, current)
        break
      end
    end
  end
  return table.concat(funcs, '\n')
end

local function parse_args(...)
  local f
  local opt = ''
  for i, a in ipairs { ... } do
    if a == '-p' or a == '-e' then
      if opt ~= '' then
        vim.api.nvim_err_writeln '-p and -e may not be used together'
        return
      end
      if a == '-p' then
        opt = '-parallel'
      else
        opt = '-exported'
      end
    else
      if i ~= #... then
        vim.api.nvim_err_writeln 'too many arguments to :GoAddTest'
        return
      else
        f = a
        break
      end
    end
  end
  return opt, f
end

function M.add(...)
  local opt, f = parse_args(...)
  if opt == nil then
    return
  end
  if f == nil then
    local func = ts.get_current_function_name()
    if func == nil then
      vim.api.nvim_err_writeln 'Cannot determine test to add. Please provide a test name.'
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
  print(vim.inspect { ... })
  local args = ''
  for _, a in ipairs { ... } do
    args = string.format('%s %s', args, a)
  end
  local fp = vim.fn.expand '%'
  if vim.fn.isdirectory(fp) > 0 then
    vim.api.nvim_err_writeln 'Current file is a directory'
    return
  end
  if fs.is_test_file(fp) then
    vim.api.nvim_err_writeln 'Current file is a test file'
    return
  end
  local cmd = string.format('gotests -w %s %s', args, fp)
  local ok = false
  local out = ''
  print(cmd)
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
        print 'Test(s) generated.'
      else
        vim.api.nvim_err_writeln(string.format('Failed to generate tests. %s (code %d)', vim.inspect(out), code))
      end
    end,
  })
end

return M
