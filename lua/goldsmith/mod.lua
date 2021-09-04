local cmds = require 'goldsmith.lsp.commands'
local ts = require 'goldsmith.treesitter'
local job = require 'goldsmith.job'
local log = require 'goldsmith.log'

local M = {}

function M.check_for_upgrades()
  local modules = ts.get_all_modules()
  cmds.check_for_upgrades(modules)
end

function M.tidy()
  vim.cmd [[ silent! wall ]]
  cmds.tidy()
end

function M.replace(args)
  local replace, mod
  if #args < 1 then
    log.error(nil, 'Too few arguments to :GoModReplace')
    return
  end
  if #args == 1 then
    replace = args[1]
  elseif #args == 2 then
    mod = args[1]
    replace = args[2]
  else
    log.error(nil, 'Too many arguments to :GoModReplace')
    return
  end
  if mod == nil then
    mod = ts.get_module_at_cursor()
    if mod == nil then
      log.error(nil, 'There is no module at the current position')
      return
    end
  end
  vim.cmd [[ silent! wall ]]
  local b = vim.api.nvim_get_current_buf()
  local cmd
  if type(mod) == 'table' then
    cmd = string.format('go mod edit -replace %s@%s=%s', mod.name, mod.version, replace)
  else
    cmd = string.format('go mod edit -replace %s=%s', mod, replace)
  end
  job.run(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stderr = function(chan, data, name)
      log.error(nil, data[1])
    end,
    on_exit = function(jobid, code, event)
      if code > 0 then
        return
      end
      vim.api.nvim_buf_call(b, function()
        vim.cmd [[ silent! e! ]]
      end)
      log.info('Mod', 'Replaced module')
    end,
  })
end

function M.format()
  vim.cmd [[ silent! wall ]]
  local b = vim.api.nvim_get_current_buf()
  job.run('go mod edit -fmt', {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stderr = function(chan, data, name)
      log.error(nil, data[1])
    end,
    on_exit = function(jobid, code, event)
      if code > 0 then
        return
      end
      vim.api.nvim_buf_call(b, function()
        vim.cmd [[ silent! e! ]]
      end)
      log.info('Mod', 'Requested formatting is done.')
    end,
  })
end

return M
