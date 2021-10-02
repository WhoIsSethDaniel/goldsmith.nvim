local job = require 'goldsmith.job'
local config = require 'goldsmith.config'

local M = {}

local last = {}

function M.run(args)
  args = args or {}
  if #args == 0 then
    table.insert(args, vim.fn.fnamemodify(vim.fn.expand '%', ':p:h'))
  end
  local cmd = { 'go', 'run'}

  vim.list_extend(cmd, args)

  last = { cmd, config.terminal_opts 'gorun' }
  job.run(unpack(last))
end

function M.last(args)
  local cmd, opts = unpack(last)
  vim.list_extend(cmd, args or {})
  job.run(cmd, opts)
end

return M
