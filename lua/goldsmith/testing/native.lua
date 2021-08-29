local config = require 'goldsmith.config'
local wb = require 'goldsmith.winbuf'
local fs = require 'goldsmith.fs'
local log = require 'goldsmith.log'
local ts = require 'goldsmith.treesitter'
local job = require 'goldsmith.job'

local M = {}

function M.has_requirements()
  return true
end

function M.setup_command(args)
  -- for future use
end

local function get_last_file(f)
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
        last_file = get_last_file(cf)
        if #args > 0 then
          local new = {}
          table.insert(new, '-run=' .. table.concat(args, '$|') .. '$')
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
        last_file = get_last_file(cf)
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
          else
            log.warn('Test', 'Cannot determine current function.')
            return false
          end
        else
          log.warn('Test', 'Cannot determine type of file.')
          return false
        end
        last_file = get_last_file(cf)
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
        job.run(cmd, vim.tbl_deep_extend('force', config.get 'gotest', config.get 'terminal', { terminal = true }), {
          stdout_buffered = true,
          stderr_buffered = true,
          on_error = function(id, data)
            -- empty
          end,
          on_stdout = function(id, data)
            -- empty
          end,
          on_exit = function() end,
        })
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
