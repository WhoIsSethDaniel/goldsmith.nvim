local log = require 'goldsmith.log'

local M = {}

function M.list(args)
  local cmd = string.format('go list -json %s', args)
  local out = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    log.error('Go', string.format("Failed to run '%s'", cmd))
    return
  end
  for i, e in ipairs(out) do
    if e == '}' and out[i+1] == '{' then
      out[i] = '},'
    end
  end
  return vim.fn.json_decode('['..table.concat(out,'')..']')
end

return M
