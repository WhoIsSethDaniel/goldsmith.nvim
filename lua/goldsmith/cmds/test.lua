local config = require 'goldsmith.config'
local job = require 'goldsmith.job'
local log = require 'goldsmith.log'
local fs = require 'goldsmith.fs'

local M = {}

function M.run(bang, args)
  local has_file_arg = false
  for i, arg in ipairs(args) do
    if arg == '--' then
      table.remove(args, i)
      table.insert(args, i, fs.relative_to_cwd(vim.fn.expand '%'))
      has_file_arg = true
      break
    end
    if fs.is_valid_package(arg) then
      has_file_arg = true
      break
    end
  end
  if not has_file_arg then
    table.insert(args, fs.relative_to_cwd(vim.fn.expand '%'))
  end

  local cmd = vim.list_extend({ 'go', 'test' }, args)
  local opts = {}
  if bang == '' then
    opts = config.terminal_opts('gotest', { title = table.concat(cmd, ' ') })
  end

  job.run(cmd, opts, {
    on_exit = function(id, code)
      log.info('Testing', string.format("Command '%s' finished with code %d", table.concat(cmd, ' '), code))
    end,
  })
end

return M
