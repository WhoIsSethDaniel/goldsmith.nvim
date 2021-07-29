local M = {}

function M.list_known_packages(buf)
  local resp = vim.lsp.buf_request_sync(buf, 'workspace/executeCommand', {
    command = 'gopls.list_known_packages',
    arguments = { { URI = vim.uri_from_bufnr(buf) } },
  })
  local pkgs = {}
  for _, response in pairs(resp) do
    if response.result ~= nil then
      pkgs = response.result.Packages
      break
    end
  end
  return pkgs
end

return M
