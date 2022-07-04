local config = require 'goldsmith.config'
local ac = require 'goldsmith.autoconfig'

local M = {}

function M.maybe_run()
  if ac.all_servers_are_running() then
    if config.get('highlight', 'current_symbol') == true then
      vim.lsp.buf.clear_references()
      vim.lsp.buf.document_highlight()
    end
  end
end

return M
