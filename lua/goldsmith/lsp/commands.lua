local log = require 'goldsmith.log'

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

local function check_for_error(msg)
  if msg ~= nil and type(msg[1]) == 'table' then
    for k, v in pairs(msg[1]) do
      if k == 'error' then
        log.error('LSP', v.message)
        break
      end
    end
  end
end

function M.update_go_sum()
  local b = vim.api.nvim_get_current_buf()
  local resp = vim.lsp.buf_request_sync(b, 'workspace/executeCommand', {
    command = 'gopls.update_go_sum',
    arguments = { { URIs = { vim.uri_from_bufnr(b) } } },
  })
  check_for_error(resp)
end

function M.tidy()
  local b = vim.api.nvim_get_current_buf()
  local resp = vim.lsp.buf_request_sync(b, 'workspace/executeCommand', {
    command = 'gopls.tidy',
    arguments = { { URIs = { vim.uri_from_bufnr(b) } } },
  })
  check_for_error(resp)
end

function M.check_for_upgrades(modules)
  local b = vim.api.nvim_get_current_buf()
  local resp = vim.lsp.buf_request_sync(b, 'workspace/executeCommand', {
    command = 'gopls.check_upgrades',
    arguments = {
      {
        URI = vim.uri_from_bufnr(b),
        Modules = modules,
      },
    },
  })
  check_for_error(resp)
end

return M
