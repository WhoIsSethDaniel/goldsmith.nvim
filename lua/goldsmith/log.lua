local wb = require 'goldsmith.winbuf'
local config = require 'goldsmith.config'

local M = {}
local debug_wb = {}

local function log_string(label, msg)
  if type(msg) == 'function' then
    msg = msg()
  end
  if label then
    return string.format('Goldsmith: %s: %s', label, msg)
  else
    return string.format('Goldsmith: %s', msg)
  end
end

local function debug_log(lvl, cat, msg)
  if debug_wb ~= nil and vim.api.nvim_buf_is_loaded(debug_wb.buf) then
    if type(msg) == 'function' then
      msg = msg()
    end
    local ndx = vim.api.nvim_buf_line_count(debug_wb.buf)
    vim.api.nvim_buf_set_lines(
      debug_wb.buf,
      ndx,
      ndx,
      true,
      vim.split(string.format('%s: %s: %s', lvl, cat, msg), '\n')
    )
  end
end

local function log(debug, lvl)
  if not debug and lvl == 'debug' then
    return function() end
  end
  if lvl == 'error' then
    if debug then
      return function(label, msg)
        vim.api.nvim_err_writeln(log_string(label, msg))
        debug_log(lvl, label, msg)
      end
    else
      return function(label, msg)
        vim.api.nvim_err_writeln(log_string(label, msg))
      end
    end
  else
    if debug then
      return function(label, msg)
        if lvl ~= 'debug' then
          print(log_string(label, msg))
        end
        debug_log(lvl, label, msg)
      end
    else
      return function(label, msg)
        print(log_string(label, msg))
      end
    end
  end
end

function M.toggle_debug_console()
  if not M.is_debug() then
    M.info('Debug', 'Debugging is not turned on. To turn on debugging set debug.enable to true and restart nvim.')
    return
  end
  debug_wb = wb.toggle_debug_console(debug_wb, vim.tbl_deep_extend('force', config.get 'window', config.get 'debug'))
end

function M.init()
  local d = config.get('debug', 'enable')
  M.error = log(d, 'error')
  M.info = log(d, 'info')
  M.debug = log(d, 'debug')
  M.is_debug = function()
    return d
  end

  if d then
    debug_wb = wb.create_debug_buffer()
    require('goldsmith.tools').dump()
    require('goldsmith.config').dump()
  end
end

return M
