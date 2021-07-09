-- local lspconfig = require'lspconfig/configs'

local M = {}

function M.dump()
  print(vim.inspect(vim.lsp.get_active_clients()))
end


return M
