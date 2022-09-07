local config = require 'goldsmith.config'
local ac = require 'goldsmith.autoconfig'

local M = {
  gopls = {
    ready = false,
  },
}

function M.check_for_ready(msgs)
  if config.get('status', 'use_event') then
    -- print(vim.inspect(msgs))
    for _, msg in ipairs(msgs) do
      local client_name = msg.name
      if client_name == 'gopls' and msg.done then
        M.gopls.ready = true
      end
    end
  end
end

function M.is_ready()
  if config.get('status', 'use_event') then
    return ac.all_servers_are_running() and M.gopls.ready
  else
    return ac.all_servers_are_running()
  end
end

return M
