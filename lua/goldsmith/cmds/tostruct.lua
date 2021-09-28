local job = require 'goldsmith.job'
local log = require 'goldsmith.log'
local config = require 'goldsmith.config'

local M = {}

function M.run(given, args)
  local json
  if given.count > -1 then
    json = vim.api.nvim_buf_get_lines(0, given.line1, given.line2, true)
  else
    local register = config.get('gotostruct', 'fetch_register')
    json = vim.fn.getreg(register)
    if json == '' then
      log.warn('ToStruct', string.format("Register '%s' is empty.", register))
      return
    end
    json = vim.split(json, '\n')
  end
  json = vim.tbl_map(function(e)
    return string.match(e, '^%s*//+([^/].*)$') or string.match(e, '^%s*#+([^#].*)$') or string.match(e, '^(.*)$')
  end, json)
  json = table.concat(json, '\n')
  local b = vim.api.nvim_get_current_buf()
  local out
  local chan = job.run({ 'json-to-struct', '-name', args[1] or config.get('gotostruct', 'struct_name') }, {
    stderr_buffered = true,
    stdout_buffered = true,
    on_stderr = function(id, data)
      if data[1] ~= '' then
        log.error('ToStruct', string.format('Failed to convert JSON to struct: %s', table.concat(data, '')))
      end
    end,
    on_stdout = function(id, data)
      table.remove(data, 1) -- remove package
      table.remove(data, 1) -- remove empty line
      table.remove(data) -- remove empty line
      out = data
    end,
    on_exit = function(id, code)
      if code ~= 0 then
        return
      end
      if given.type == 'register' then
        local register = config.get('gotostruct', 'store_register')
        vim.fn.setreg(register, table.concat(out, '\n'))
        log.info('ToStruct', string.format("JSON converted and placed in register '%s'", register))
      else
        vim.api.nvim_buf_set_lines(b, given.line1 - 1, given.line2, true, out)
        log.info('ToStruct', 'JSON converted and pasted')
      end
    end,
  })
  vim.fn.chansend(chan, json)
end

return M
