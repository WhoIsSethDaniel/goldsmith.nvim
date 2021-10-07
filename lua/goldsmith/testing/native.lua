local config = require 'goldsmith.config'
local wb = require 'goldsmith.winbuf'
local fs = require 'goldsmith.fs'
local log = require 'goldsmith.log'
local ts = require 'goldsmith.treesitter'
local job = require 'goldsmith.job'
local cmds = require 'goldsmith.cmds'

local M = {}

function M.has_requirements()
  return true
end

local function set_last_file(f)
  if fs.is_test_file(f) then
    return f
  else
    return fs.test_file_name(f)
  end
end

local test_acts = {
  -- grab the panic description; should come before matching the file and line number
  {
    on = 'output',
    match = '^\tpanic: (.*)$',
    act = function(state, args)
      state['last_panic'] = args.matches[1]
    end,
  },
  -- standard file, line number, error message output
  {
    on = 'output',
    match = '^%s+(.+%.go):(%d+):%s*(.*)$',
    act = function(state, args)
      local m = {
        file = args.matches[1],
        line = args.matches[2],
        mess = args.matches[3],
      }
      local fail_rel_path = string.sub(args.j.Package, string.len(args.module) + 2)
      if fail_rel_path ~= '' then
        m.file = fail_rel_path .. '/' .. m.file
      end
      return m
    end,
  },
  -- a panic; the file and line number
  {
    on = 'output',
    match = '^\t(/.+%.go):(%d+) %+0x.*$',
    act = function(state, args)
      local m = {
        mess = state['last_panic'] or 'panic',
        file = args.matches[1],
        line = args.matches[2],
      }
      m.file = string.sub(m.file, string.len(vim.fn.getcwd()) + 2)
      return m
    end,
  },
  -- sometimes 'go test -json' does not actually return json. Instead it prints (most)
  -- of its output to stderr. This deals with that case.
  {
    on = 'stderr_output',
    match = '^(.+%.go):(%d+):%d+: (.*)$',
    act = function(state, args)
      return {
        file = args.matches[1],
        line = args.matches[2],
        mess = args.matches[3],
      }
    end,
  },
}

do
  local test_type, args, cmd, cf, last_file, last_cmd, last_win, current_job, last_job
  local function is_bench()
    return test_type == 'bench'
  end
  local function is_test()
    return test_type == 'test'
  end
  local function is_any()
    return test_type == 'any'
  end
  local dispatch = {
    last = {
      function()
        if last_cmd == nil then
          log.warn('Testing', 'There is no last test command to run.')
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
            log.error('GoTestVisit', string.format('%s: file does not exist', f))
            return false
          end
        end

        local window_cfg = config.window_opts('gotestvisit', { file = f })
        if window_cfg['use_current_window'] then
          vim.cmd(string.format('silent! e! %s', f))
          vim.cmd [[ silent! w! ]]
          return true
        end
        local win = wb.find_window_by_name(f)
        if win ~= nil then
          vim.fn.win_gotoid(win)
        else
          wb.create_winbuf(window_cfg)
        end
        -- returning false suppresses job running
        return false
      end,
    },
    run = {
      function()
        last_file = set_last_file(cf)
        if #args > 0 then
          local scope = fs.relative_to_cwd(cf)
          for i, arg in ipairs(args) do
            if arg == './...' then
              table.remove(args, i)
              scope = './...'
            elseif arg == '...' then
              table.remove(args, i)
              scope = scope .. '/...'
            end
          end
          local new = {}
          if is_any() then
            table.insert(new, 1, '-run=' .. table.concat(args, '$|') .. '$')
            table.insert(new, 1, '-bench=' .. table.concat(args, '$|') .. '$')
          elseif is_bench() then
            table.insert(new, 1, '-run=#')
            table.insert(new, 1, '-bench=' .. table.concat(args, '$|') .. '$')
          elseif is_test() then
            table.insert(new, 1, '-run=' .. table.concat(args, '$|') .. '$')
          end
          table.insert(new, scope)
          args = new
          return true
        else
          return true, 'pkg'
        end
      end,
    },
    nearest = {
      function()
        if fs.is_code_file(cf) then
          local tf = fs.test_file_name(cf)
          if vim.fn.filereadable(tf) == 0 then
            log.warn('Testing', string.format("No test file for '%s'", cf))
            return false
          end
          local cfunc = ts.get_current_function_name()
          if cfunc ~= nil then
            local b = wb.create_test_file_buffer(tf)
            local tests = vim.api.nvim_buf_call(b, function()
              return ts.get_all_functions()
            end)
            local possible_test_names
            if is_bench() then
              possible_test_names = {
                string.format('Benchmark%s', cfunc),
                string.format('Benchmark_%s', cfunc),
              }
            elseif is_test() then
              possible_test_names = {
                string.format('Test_%s', cfunc),
                string.format('Test%s', cfunc),
                string.format('Example%s', cfunc),
              }
            elseif is_any() then
              possible_test_names = {
                string.format('Benchmark%s', cfunc),
                string.format('Benchmark_%s', cfunc),
                string.format('Test_%s', cfunc),
                string.format('Test%s', cfunc),
                string.format('Example%s', cfunc),
              }
            end
            local match = false
            local any_matches = {}
            for _, test in ipairs(tests) do
              if vim.tbl_contains(possible_test_names, test.name) then
                match = true
                if is_any() then
                  table.insert(any_matches, test.name)
                elseif is_bench() then
                  table.insert(args, 1, '-run=#')
                  table.insert(args, 1, string.format('-bench=%s$', test.name))
                elseif is_test() then
                  table.insert(args, 1, string.format('-run=%s$', test.name))
                end
                if not is_any() then
                  break
                end
              end
            end
            if match == false then
              log.warn('Testing', string.format("Cannot find matching test for function '%s'", cfunc))
              return false
            end
            if is_any() then
              table.insert(args, 1, '-run=' .. table.concat(any_matches, '$|') .. '$')
              table.insert(args, 1, '-bench=' .. table.concat(any_matches, '$|') .. '$')
            end
            table.insert(args, fs.relative_to_cwd(cf))
          else
            log.warn('Testing', 'Cannot determine current function.')
            return false
          end
        elseif fs.is_test_file(cf) then
          local cfunc = ts.get_current_function_name()
          if cfunc ~= nil then
            if is_any() then
              table.insert(args, 1, string.format('-bench=%s$', cfunc))
              table.insert(args, 1, string.format('-run=%s$', cfunc))
            elseif is_bench() then
              if string.match(cfunc, '^Benchmark') ~= nil then
                table.insert(args, 1, '-run=#')
                table.insert(args, 1, string.format('-bench=%s$', cfunc))
              else
                log.warn('Testing', string.format("Current function '%s' does not look like a benchmark", cfunc))
                return false
              end
            elseif is_test() then
              if string.match(cfunc, '^Test') ~= nil or string.match(cfunc, '^Example') ~= nil then
                table.insert(args, 1, string.format('-run=%s', cfunc))
              else
                log.warn('Testing', string.format("Current function '%s' does not look like a test", cfunc))
                return false
              end
            end
            table.insert(args, fs.relative_to_cwd(cf))
          else
            log.warn('Testing', 'Cannot determine current function.')
            return false
          end
        else
          log.warn('Testing', 'Cannot determine type of file.')
          return false
        end
        last_file = set_last_file(cf)
        return true
      end,
    },
    suite = {
      function()
        if is_any() then
          table.insert(args, 1, '-bench=.')
        elseif is_bench() then
          table.insert(args, 1, '-run=#')
          table.insert(args, 1, '-bench=.')
        end
        table.insert(args, './...')
        return true
      end,
    },
    pkg = {
      function()
        args = cmds.process_args(args)
        if is_any() then
          table.insert(args, 1, '-bench=.')
        elseif is_bench() then
          table.insert(args, 1, '-run=#')
          table.insert(args, 1, '-bench=.')
        end
        return true
      end,
    },
  }
  for act, d in pairs(dispatch) do
    M[act] = function(...)
      args = { ... }
      if args[2] ~= nil then
        test_type = args[1]['type'] or 'test'
        args = args[2]
      elseif args[1] ~= nil then
        test_type = args[1]['type'] or 'test'
        args[1]['type'] = nil
        args = args[1]
      else
        test_type = 'test'
      end
      cmd = nil
      cf = vim.fn.expand '%'
      local ok, next = d[1]()
      if next ~= nil then
        return M[next] {}
      end
      if ok then
        if current_job ~= nil then
          last_job = current_job
          if vim.fn.jobwait({ last_job }, 0)[1] == -1 then
            log.warn('Testing', 'Killing currently running test job')
            vim.fn.jobstop(last_job)
          end
        end
        if cmd == nil then
          cmd = vim.list_extend({ 'go', 'test' }, vim.tbl_flatten { config.get('testing', 'arguments'), args })
        end
        last_cmd = cmd
        local opts = {}
        local strategy = config.get('testing', 'strategy')
        if strategy == 'display' then
          opts = config.window_opts(
            'testing',
            { keymap = 'testing', create = true, title = table.concat(cmd, ' '), reuse = 'test_native' }
          )
          last_win = wb.create_winbuf(opts)
          wb.clear_buffer(last_win.buf)
          wb.make_buffer_plain(last_win.buf, last_win.win, { ft = 'gotest' })
          wb.set_close_keys(last_win.buf)
          wb.setup_follow_buffer(last_win.buf)
        end
        table.insert(cmd, 3, '-json')
        local out = {}
        local decoded = {}
        local on_output = function(id, data, name)
          if id == last_job then
            return
          end
          if data then
            vim.list_extend(out, data)
            local last = table.remove(data)
            if #out > 1 then
              for _, l in ipairs(out) do
                if l ~= '' then
                  local ok, jd = pcall(vim.fn.json_decode, l)
                  if not ok then
                    table.insert(decoded, { Action = 'stderr_output', Output = l })
                    if strategy == 'display' then
                      wb.append_to_buffer(last_win.buf, { l })
                    end
                  else
                    table.insert(decoded, jd)
                    if strategy == 'display' and jd.Action == 'output' then
                      wb.append_to_buffer(last_win.buf, { (vim.split(jd.Output, '\n'))[1] })
                    end
                  end
                end
              end
            end
            out = { last }
          end
        end
        current_job = job.run(cmd, opts, {
          on_stderr = on_output,
          on_stdout = on_output,
          on_exit = function(id, code)
            -- if this is a job that has been killed and superseded, move on
            if id == last_job then
              last_job = nil
              return
            end
            if strategy == 'display' then
              wb.append_to_buffer(last_win.buf, { '', "[Press 'q' or '<Esc>' to close window]" })
            end
            -- get rid of -json
            table.remove(cmd, 3)
            if code == 0 then
              log.info('Testing', string.format("Command '%s' ran successfully.", table.concat(cmd, ' ')))
              return
            else
              log.info('Testing', string.format("Command '%s' did not run successfully.", table.concat(cmd, ' ')))
            end
            local qflist = job.check_for_errors(test_acts, decoded)
            if #qflist > 0 then
              vim.fn.setqflist({}, ' ', { nr = '$', items = qflist, title = table.concat(cmd, ' ') })
              local w = vim.api.nvim_get_current_win()
              vim.cmd [[ copen ]]
              vim.api.nvim_set_current_win(w)
            end
          end,
        })
      end
    end
  end
end

function M.create_commands()
  vim.api.nvim_exec(
    [[
      command! -nargs=* -bar -complete=custom,v:lua.goldsmith_test_complete GoTestRun  lua require'goldsmith.testing.native'.run({type='test'},  {<f-args>})
      command! -nargs=* -bar -complete=custom,v:lua.goldsmith_test_complete GoTestBRun lua require'goldsmith.testing.native'.run({type='bench'}, {<f-args>})
      command! -nargs=* -bar -complete=custom,v:lua.goldsmith_test_complete GoTestARun lua require'goldsmith.testing.native'.run({type='any'},   {<f-args>})

      command! -nargs=* -bar -complete=custom,v:lua.goldsmith_package_complete GoTestPkg  lua require'goldsmith.testing.native'.pkg({type='test'},  {<f-args>})
      command! -nargs=* -bar -complete=custom,v:lua.goldsmith_package_complete GoTestBPkg lua require'goldsmith.testing.native'.pkg({type='bench'}, {<f-args>})
      command! -nargs=* -bar -complete=custom,v:lua.goldsmith_package_complete GoTestAPkg lua require'goldsmith.testing.native'.pkg({type='any'},   {<f-args>})

      command! -nargs=* -bar                GoTestNearest  lua require'goldsmith.testing.native'.nearest({type='test'},  {<f-args>})
      command! -nargs=* -bar                GoTestBNearest lua require'goldsmith.testing.native'.nearest({type='bench'}, {<f-args>})
      command! -nargs=* -bar                GoTestANearest lua require'goldsmith.testing.native'.nearest({type='any'},   {<f-args>})

      command! -nargs=* -bar                GoTestSuite    lua require'goldsmith.testing.native'.suite({type='test'},  {<f-args>})
      command! -nargs=* -bar                GoTestBSuite   lua require'goldsmith.testing.native'.suite({type='bench'}, {<f-args>})
      command! -nargs=* -bar                GoTestASuite   lua require'goldsmith.testing.native'.suite({type='any'},   {<f-args>})

      command! -nargs=* -bar                GoTestLast     lua require'goldsmith.testing.native'.last({<f-args>})
      command!          -bar -bang          GoTestVisit    lua require'goldsmith.testing.native'.visit({'<bang>'})
    ]],
    false
  )
end

return M
