local M = {}

function M.config()
  require'goldsmith.lsp.autoconfig.gopls'.config()
end

return M
