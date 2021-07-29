local job = require 'goldsmith.job'
local config = require 'goldsmith.config'

local M = {}

function M.run()
  local dry = 1
  local cfg = config.get 'gofixplurals' or {}
  local changed = {}
  local err = {}
  local cf = vim.fn.fnamemodify(vim.fn.expand '%', ':p')
  local b = vim.api.nvim_get_current_buf()
  cfg['stderr_buffered'] = true
  cfg['stdout_buffered'] = true
  cfg['on_stdout'] = function(id, data, name)
    for _, l in ipairs(data) do
      local m = string.match(l, '^--- (.*)$')
      if m ~= nil then
        table.insert(changed, m)
      end
    end
  end
  cfg['on_stderr'] = function(id, data, name)
    for _, l in ipairs(data) do
      if l ~= '' then
        table.insert(err, l)
      end
    end
  end
  cfg['on_exit'] = function(id, code, event)
    if #err ~= 0 then
      vim.api.nvim_err_writeln(table.concat(err, '\n'))
      return
    end
    if code > 0 then
      return
    end
    if #changed > 0 then
      if dry == 0 then
        for _, f in ipairs(changed) do
          if f == cf then
            vim.api.nvim_buf_call(b, function()
              vim.cmd [[ :e! ]]
            end)
          end
        end
        print(string.format('GoFixPlurals: file(s) changed: %s', table.concat(changed, ', ')))
      else
        dry = 0
        job.run(string.format('fixplurals %s', vim.fn.expand '%'), cfg)
      end
    else
      print 'GoFixPlurals: no files changed'
    end
  end
  if vim.opt.modified:get() == true then
    vim.api.nvim_err_writeln 'GoFixPlurals: cannot change a modified file. Save prior to running.'
  else
    job.run(string.format('fixplurals -dry %s', vim.fn.expand '%'), cfg)
  end
end

return M
