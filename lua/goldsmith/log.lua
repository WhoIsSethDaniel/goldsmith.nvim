local config = require 'goldsmith.config'

local M = {}

local logfile = string.format('%s/%s', vim.fn.stdpath 'cache', 'goldsmith.log')

local function log_string(label, msg)
  if type(msg) == 'function' then
    msg = msg()
  end
  if label then
    return string.format('Goldsmith: %s: %s\n', label, msg)
  else
    return string.format('Goldsmith: %s\n', msg)
  end
end

local function log_to_file(msg)
  local l = assert(io.open(logfile, 'a'))
  l:write(msg)
  l:close()
end

local function log(debug, lvl)
  if not debug and lvl == 'debug' then
    return function() end
  end
  local logger
  if lvl == 'error' then
    logger = vim.api.nvim_err_writeln
  elseif lvl == 'warn' then
    logger = function(msg)
      vim.api.nvim_echo({ { msg, 'WarningMsg' } }, true, {})
    end
  elseif lvl == 'info' then
    logger = print
  end
  if debug then
    return function(label, msg)
      local lstr = log_string(label, msg)
      if lvl ~= 'debug' then
        logger(lstr)
      end
      log_to_file(lstr)
    end
  else
    return function(label, msg)
      local lstr = log_string(label, msg)
      logger(log_string(lstr))
      log_to_file(lstr)
    end
  end
end

function M.setup()
  local d = config.get('system', 'debug')
  M.error = log(d, 'error')
  M.warn = log(d, 'warn')
  M.info = log(d, 'info')
  M.debug = log(d, 'debug')
  M.is_debug = function()
    return d
  end

  if d then
    M.debug('Version', function()
      return vim.api.nvim_exec('version', true)
    end)
    M.debug('Version', function()
      return vim.inspect(vim.version())
    end)
    require('goldsmith.tools').dump()
    require('goldsmith.config').dump()
  end
end

return M
