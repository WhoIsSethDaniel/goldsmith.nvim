local config = require 'goldsmith.config'

local M = {}

function M.current_symbol()
  if config.get('highlight')['current_symbol'] == true then
    vim.lsp.buf.clear_references()
    vim.lsp.buf.document_highlight()
  end
end

return M
