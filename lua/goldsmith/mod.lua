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

function M.retract(args)
  local cmd = { 'go', 'mod', 'edit' }
  for _, vr in ipairs(args) do
    if string.match(vr, ',') then
      table.insert(cmd, '-retract=[' .. vr .. ']')
    else
      table.insert(cmd, '-retract=' .. vr)
    end
  end
  vim.cmd [[ silent! wall ]]
  local b = vim.api.nvim_get_current_buf()
  job.run(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stderr = function(id, data)
      log.error('Mod', data[1])
    end,
    on_exit = function(id, code)
      if code > 0 then
        return
      end
      vim.api.nvim_buf_call(b, function()
        vim.cmd [[ silent! e! ]]
      end)
      log.info('Mod', 'Retraction(s) added')
    end,
  })
end

function M.exclude(args)
  local cmd = { 'go', 'mod', 'edit' }
  if #args > 0 then
    for _, mod in ipairs(args) do
      if not string.match(mod, '@') then
        log.error('Mod', 'Module name must include a version.')
        return
      end
      table.insert(cmd, '-exclude=' .. mod)
    end
  else
    local mod = ts.get_module_at_cursor()
    if mod == nil then
      log.error('Mod', 'There is no module at the current position')
      return
    end
    table.insert(cmd, string.format('-exclude=%s@%s', mod.name, mod.version))
  end
  vim.cmd [[ silent! wall ]]
  local b = vim.api.nvim_get_current_buf()
  job.run(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stderr = function(chan, data, name)
      log.error('Mod', data[1])
    end,
    on_exit = function(jobid, code, event)
      if code > 0 then
        return
      end
      vim.api.nvim_buf_call(b, function()
        vim.cmd [[ silent! e! ]]
      end)
      log.info('Mod', 'Excluded module')
    end,
  })
end

function M.replace(args)
  local replace, mod
  if #args == 1 then
    replace = args[1]
  elseif #args == 2 then
    mod = args[1]
    replace = args[2]
  else
    log.error('Mod', 'Too many arguments to :GoModReplace')
    return
  end
  if mod == nil then
    mod = ts.get_module_at_cursor()
    if mod == nil then
      log.error('Mod', 'There is no module at the current position')
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
      log.error('Mod', data[1])
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
      log.error('Mod', data[1])
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
