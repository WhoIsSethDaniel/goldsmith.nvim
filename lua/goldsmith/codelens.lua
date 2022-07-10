local config = require 'goldsmith.config'
local ac = require 'goldsmith.autoconfig'

local M = {}

function M.maybe_run()
  if ac.all_servers_are_running() then
    if config.get('codelens', 'show') == true then
      vim.lsp.codelens.refresh()
    end
  end
end

return M
