local M = {}

function M.run()
  return vim.lsp.buf.formatting_seq_sync()
end

return M
