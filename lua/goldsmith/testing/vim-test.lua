local config = require 'goldsmith.config'
local wb = require 'goldsmith.winbuf'
local fs = require 'goldsmith.fs'
local log = require 'goldsmith.log'
local ts = require 'goldsmith.treesitter'
local plugins = require 'goldsmith.plugins'
local t = require 'goldsmith.testing'

local M = {}

function M.has_requirements()
  if not plugins.is_installed 'test' then
    log.warn('Testing', "vim-test is not installed. testing.runner may not be set to 'vim-test'.")
    return false
  end
  return true
end

-- test - GoTest
-- nearest - GoTestNearest
-- file - GoTestFile
-- suite - GoTestSuite
-- last - GoTestLast
-- visit - GoTestVisit
-- ----------------------
-- test: can pass in a test to run; if no test passed than act like GoTestFile
-- nearest: if code file, check to see if current 'nearest' function has a test, if so, runs it;
--          otherwise drops back to default
-- file: if code file, run the tests for the  package for the current file; if it cannot do this
--       it drops back to default
-- suite: similar to 'file'
-- last: same as default
-- visit: same as default, but honors window settings

function M.setup_command(args)
  if vim.g['test#strategy'] == nil then
    local strategy = t.testing_strategy()
    if strategy == nil then
      vim.g['test#strategy'] = config.vim_test_default_strategy()
    else
      vim.g['test#strategy'] = strategy
    end
  end
  if vim.g['test#strategy'] == 'neovim' and vim.g['test#neovim#term_position'] == nil then
    local term = config.get 'terminal'
    local win = wb.determine_window { pos = term.pos, width = term.width, height = term.height }
    vim.g['test#neovim#term_position'] = string.format('%s %s', win.orient, win.place)
  end
end

do
  local args, test_cmd, cf
  local dispatch = {
    last = {
      ':TestLast',
      function()
        return true
      end,
    },
    visit = {
      ':TestVisit',
      function()
        local bang = table.remove(args, 1)
        local f
        if vim.g['test#last_position'] == nil then
          test_cmd = nil
          f = vim.fn.fnamemodify(fs.alternate_file_name(cf), ':p')

          if vim.fn.getftype(f) == '' and bang == '' then
            log.error('GoTestVisit', string.format('%s: file does not exist', f))
            return false
          end
        else
          f = vim.g['test#last_position'].file
        end

        local window_cfg = config.window_opts('gotestvisit', { file = f })
        local b = vim.api.nvim_get_current_buf()
        if not window_cfg['use_current_window'] then
          local win = wb.find_window_by_name(f)
          if win ~= nil then
            vim.fn.win_gotoid(win)
          else
            wb.create_winbuf(window_cfg)
          end
        end
        return true, function()
          return ''
        end, function()
          if not window_cfg['focus'] then
            vim.api.nvim_set_current_buf(b)
          end
        end
      end,
    },
    run = {
      ':TestFile',
      function()
        if #args > 0 then
          local new = {}
          table.insert(new, '-run=' .. table.concat(args, '$\\\\|') .. '$')
          args = new
        end
        if fs.is_code_file(cf) then
          local tf = fs.test_file_name(cf)
          local lp = vim.g['test#last_position']
          if lp == nil or lp['file'] ~= tf then
            vim.g['test#last_position'] = {
              file = tf,
              line = 1,
              col = 1,
            }
          end
        end
        return true
      end,
    },
    nearest = {
      ':TestNearest',
      function()
        if fs.is_code_file(cf) then
          local cfunc = ts.get_current_function_name()
          if cfunc ~= nil then
            local tf = fs.test_file_name(cf)
            local b = wb.create_test_file_buffer(tf)
            local tests = vim.api.nvim_buf_call(b, function()
              return ts.get_all_functions()
            end)
            local possible_test_names = {
              string.format('Test_%s', cfunc),
              string.format('Test%s', cfunc),
            }
            for _, t in ipairs(tests) do
              if vim.tbl_contains(possible_test_names, t.name) then
                vim.g['test#last_position'] = {
                  file = tf,
                  line = t.line + 1,
                  col = t.col,
                }
                break
              end
            end
          end
        end
        return true
      end,
    },
    suite = {
      ':TestSuite',
      function()
        if fs.is_code_file(cf) then
          local tf = fs.test_file_name(cf)
          local lp = vim.g['test#last_position']
          if lp == nil or lp['file'] ~= tf then
            vim.g['test#last_position'] = {
              file = tf,
              line = 1,
              col = 1,
            }
          end
        end
        return true
      end,
    },
    pkg = {
      ':TestFile',
      function()
        if fs.is_code_file(cf) then
          local tf = fs.test_file_name(cf)
          local lp = vim.g['test#last_position']
          if lp == nil or lp['file'] ~= tf then
            vim.g['test#last_position'] = {
              file = tf,
              line = 1,
              col = 1,
            }
          end
        end
        return true
      end,
    },
  }
  for cmd, d in pairs(dispatch) do
    M[cmd] = function(...)
      args = vim.tbl_flatten { ... }
      test_cmd = d[1]
      cf = vim.fn.expand '%'
      M.setup_command(args)
      local ok, build_args, after = d[2]()
      if ok then
        if build_args ~= nil then
          args = build_args()
        else
          args = string.format('%s %s', table.concat(config.get('testing', 'arguments'), ' '), table.concat(args, ' '))
        end
        if test_cmd ~= nil then
          vim.api.nvim_command(string.format('%s %s', test_cmd, args))
        end
        if after ~= nil then
          after()
        end
      end
    end
  end
end

function M.create_commands()
  vim.api.nvim_exec(
    [[
      command! -nargs=* -bar -complete=custom,v:lua.goldsmith_test_complete GoTestRun lua require'goldsmith.testing.vim-test'.run({<f-args>})
      command! -nargs=* -bar                GoTestNearest lua require'goldsmith.testing.vim-test'.nearest({<f-args>})
      command! -nargs=* -bar                GoTestSuite   lua require'goldsmith.testing.vim-test'.suite({<f-args>})
      command! -nargs=* -bar                GoTestLast    lua require'goldsmith.testing.vim-test'.last({<f-args>})
      command! -nargs=* -bar -complete=custom,v:lua.goldsmith_test_package_complete GoTestPkg lua require'goldsmith.testing.vim-test'.pkg({<f-args>})
      command!          -bar -bang          GoTestVisit   lua require'goldsmith.testing.vim-test'.visit({'<bang>'})
    ]],
    false
  )
end

return M
