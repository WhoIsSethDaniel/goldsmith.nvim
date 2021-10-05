local job = require 'goldsmith.job'
local config = require 'goldsmith.config'
local fs = require 'goldsmith.fs'
local log = require 'goldsmith.log'

local M = {}

local last = {}

function M.run(bang, args)
  args = args or {}

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

  local cmd = { 'go', 'run' }
  vim.list_extend(cmd, args)

  if bang == '' then
    last = { cmd, config.terminal_opts 'gorun' }
  else
    last = { cmd, {
      on_exit = function(id, code)
        log.info('Run', string.format('Job finished with code %d', code))
      end,
    } }
  end
  job.run(unpack(last))
end

function M.last(args)
  local cmd, opts = unpack(last)
  vim.list_extend(cmd, args or {})
  job.run(cmd, opts)
end

return M
