local buffer = require'goldsmith.buffer'
local lsp = require'vim.lsp'

local M = {}

function M.get_client_named(name)
  local buf = buffer.get_valid_buffer()
  local clients = lsp.buf_get_clients(buf)
  for id, client in pairs(clients) do
    if client.name == name then
      return id, client
    end
  end
end

return M
