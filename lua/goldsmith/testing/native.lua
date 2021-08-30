local config = require 'goldsmith.config'
local wb = require 'goldsmith.winbuf'
local fs = require 'goldsmith.fs'
local log = require 'goldsmith.log'
local ts = require 'goldsmith.treesitter'
local job = require 'goldsmith.job'
local go = require 'goldsmith.go'
local t = require 'goldsmith.testing'

local M = {}

local function errorformat()
  local goroot = go.env 'goroot'
  local indent = '%\\\\%(    %\\\\)'
  local format = {}

  -- this entire errorformat is a shameless steal from vim-go;
  -- it has taken me many weeks to figure out what it is doing and
  -- why it does it
  table.insert(format, '%-G=== RUN   %.%#')
  table.insert(format, ',%-G' .. indent .. '%#--- PASS: %.%#')
  table.insert(format, ',%G--- FAIL: %\\\\%(Example%\\\\)%\\\\@=%m (%.%#)')

  table.insert(format, ',%G' .. indent .. '%#--- FAIL: %m (%.%#)')
  table.insert(format, ',%A' .. indent .. '%#%\\t%\\+%f:%l: %m')

  table.insert(format, ',%A' .. indent .. '%#%\\t%\\+%f:%l: ')

  table.insert(format, ',%G' .. indent .. '%#%\\t%\\{2}%m')
  table.insert(format, ',%A' .. indent .. '%\\+%[%^:]%\\+: %f:%l: %m')
  table.insert(format, ',%A' .. indent .. '%\\+%[%^:]%\\+: %f:%l: ')

  table.insert(format, ',%A' .. indent .. '%\\+%f:%l: %m')
  table.insert(format, ',%A' .. indent .. '%\\+%f:%l: ')
  table.insert(format, ',%G' .. indent .. '%\\{2\\,}%m')

  table.insert(format, ',%+Gpanic: test timed out after %.%\\+')

  table.insert(format, ',%+Afatal error: %.%# [recovered]')
  table.insert(format, ',%+Apanic: %.%# [recovered]')
  table.insert(format, ',%+Afatal error: %.%#')
  table.insert(format, ',%+Apanic: %.%#')

  table.insert(format, ',%-Cgoroutine %\\d%\\+ [running]:')
  table.insert(format, ',%-C%\\t' .. goroot .. '%\\f%\\+:%\\d%\\+ +0x%[0-9A-Fa-f]%\\+')
  table.insert(format, ',%Z%\\t%f:%l +0x%[0-9A-Fa-f]%\\+')

  table.insert(format, ',%-Gruntime.goparkunlock(%.%#')
  table.insert(format, ',%-G%\\t' .. goroot .. '%\\f%\\+:%\\d%\\+')

  table.insert(format, ',%-G%\\t%\\f%\\+:%\\d%\\+ +0x%[0-9A-Fa-f]%\\+')

  table.insert(format, ',%-Cexit status %[0-9]%\\+')

  table.insert(format, ',%-CFAIL%\\t%.%#')

  table.insert(format, ',%A%f:%l:%c: %m')
  table.insert(format, ',%A%f:%l: %m')

  table.insert(format, ',%-C%\\tpanic: %.%#')
  table.insert(format, ',%G%\\t%m')

  table.insert(format, ',%-C%.%#')
  table.insert(format, ',%-G%.%#')

  return format
end

function M.has_requirements()
  return true
end

function M.setup_command(args)
  -- for future use
end

local function set_last_file(f)
  if fs.is_test_file(f) then
    return f
  else
    return fs.test_file_name(f)
  end
end

do
  local args, cmd, cf, last_file, last_cmd
  local dispatch = {
    last = {
      function()
        if last_cmd == nil then
          log.warn('Test', 'There is no last test command to run.')
          return false
        else
          cmd = last_cmd
          return true
        end
      end,
    },
    visit = {
      function()
        local bang = table.remove(args, 1)
        local f = last_file
        if f == nil then
          f = vim.fn.fnamemodify(fs.alternate_file_name(cf), ':p')

          if vim.fn.getftype(f) == '' and bang == '' then
            log.error('Test', string.format('%s: file does not exist', f))
            return false
          end
        end

        local window_cfg = vim.tbl_deep_extend('force', config.get 'window', config.get 'gotestvisit')
        if not window_cfg['use_current_window'] then
          local win = wb.find_window_by_name(f)
          if win ~= nil then
            vim.fn.win_gotoid(win)
          else
            wb.create_winbuf(vim.tbl_deep_extend('force', window_cfg, { file = f }))
          end
        end
        -- returning false suppresses job running
        return false
      end,
    },
    run = {
      function()
        last_file = set_last_file(cf)
        if #args > 0 then
          local new = {}
          table.insert(new, '-run=' .. table.concat(args, '$|') .. '$')
          table.insert(new, fs.relative_to_cwd(cf) .. '/...')
          args = new
          return true
        else
          return true, 'nearest'
        end
      end,
    },
    test = {
      function()
        table.insert(args, fs.relative_to_cwd(cf))
        last_file = set_last_file(cf)
        return true
      end,
    },
    nearest = {
      function()
        if fs.is_code_file(cf) then
          local cfunc = ts.get_current_function_name()
          local tf = fs.test_file_name(cf)
          if cfunc ~= nil and vim.fn.filereadable(tf) > 0 then
            local b = wb.create_test_file_buffer(tf)
            local tests = vim.api.nvim_buf_call(b, function()
              return ts.get_all_functions()
            end)
            local possible_test_names = {
              string.format('Test_%s', cfunc),
              string.format('Test%s', cfunc),
            }
            local match = false
            for _, t in ipairs(tests) do
              if vim.tbl_contains(possible_test_names, t.name) then
                match = true
                table.insert(args, string.format('-run=%s', t.name))
                table.insert(args, fs.relative_to_cwd(cf))
                break
              end
            end
            if match == false then
              log.warn('Test', string.format("Cannot find matching test for function '%s'", cfunc))
              return false
            end
          else
            log.warn('Test', 'Cannot determine current function.')
            return false
          end
        elseif fs.is_test_file(cf) then
          local cfunc = ts.get_current_function_name()
          if cfunc ~= nil then
            table.insert(args, string.format('-run=%s', cfunc))
            table.insert(args, fs.relative_to_cwd(cf))
          else
            log.warn('Test', 'Cannot determine current function.')
            return false
          end
        else
          log.warn('Test', 'Cannot determine type of file.')
          return false
        end
        last_file = set_last_file(cf)
        return true
      end,
    },
    suite = {
      function()
        table.insert(args, './...')
        return true
      end,
    },
    pkg = {
      function()
        if #args == 0 then
          table.insert(args, fs.relative_to_cwd(cf))
        end
        return true
      end,
    },
  }
  for act, d in pairs(dispatch) do
    M[act] = function(...)
      args = ...
      cmd = nil
      cf = vim.fn.expand '%'
      M.setup_command(args)
      local ok, next = d[1]()
      if next ~= nil then
        return M[next] {}
      end
      if ok then
        if #args == 0 then
          args = { '.' }
        end
        if cmd == nil then
          cmd = vim.list_extend({ 'go', 'test' }, vim.tbl_flatten { config.get('testing', 'arguments'), args })
        end
        last_cmd = cmd
        local out = {}
        local efm = table.concat(errorformat(), '')
        local opts = {}
        if t.testing_strategy() == 'native_terminal' then
          opts = vim.tbl_deep_extend('force', config.get 'testing', config.get 'terminal', { terminal = true })
        end
        job.run(
          cmd,
          vim.tbl_deep_extend('force', opts, {
            stdout_buffered = true,
            stderr_buffered = true,
            on_error = function(id, data)
              if data then
                vim.list_extend(out, data)
              end
            end,
            on_stdout = function(id, data)
              if data then
                vim.list_extend(out, data)
              end
            end,
            on_exit = function()
              -- only needed for terminal mode, really
              out = vim.tbl_map(function(l)
                return string.gsub(l, '\r', '')
              end, out)
              log.info('Testing', string.format("'%s': command finished", table.concat(cmd, ' ')))
              vim.fn.setqflist({}, ' ', {
                title = cmd,
                lines = out,
                efm = efm,
              })
              vim.api.nvim_command 'doautocmd QuickFixCmdPost'
              if #out > 0 then
                vim.api.nvim_command 'copen'
              end
            end,
          })
        )
      end
    end
  end
end

function M.create_commands()
  vim.api.nvim_exec(
    [[
      command! -nargs=* -bar -complete=custom,v:lua.goldsmith_test_complete GoTestRun lua require'goldsmith.testing.native'.run({<f-args>})
      command! -nargs=* -bar                GoTest        lua require'goldsmith.testing.native'.test({<f-args>})
      command! -nargs=* -bar                GoTestNearest lua require'goldsmith.testing.native'.nearest({<f-args>})
      command! -nargs=* -bar                GoTestSuite   lua require'goldsmith.testing.native'.suite({<f-args>})
      command! -nargs=* -bar                GoTestLast    lua require'goldsmith.testing.native'.last({<f-args>})
      command! -nargs=* -bar -complete=custom,v:lua.goldsmith_test_package_complete GoTestPkg lua require'goldsmith.testing.native'.pkg({<f-args>})
      command!          -bar -bang          GoTestVisit   lua require'goldsmith.testing.native'.visit({'<bang>'})
    ]],
    false
  )
end

return M
