local config = require 'goldsmith.config'

local M = {}

function M.update()
  if config.get('codelens')['show'] == true then
    vim.lsp.codelens.refresh()
  end
end

return M
