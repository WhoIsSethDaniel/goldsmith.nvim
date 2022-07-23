local config = require 'goldsmith.config'
local log = require 'goldsmith.log'
local mod = require 'goldsmith.mod'
local fs = require 'goldsmith.fs'

local M = {}

function M.configure(client)
  local caps = client.server_capabilities
  local gofmt = not config.service_is_disabled 'gofmt'
  local gofumpt = not config.service_is_disabled 'gofumpt'

  if gofmt == true or gofumpt == true then
    if client.name == 'gopls' then
      -- turn off gopls doc formatting
      log.debug('Format', 'Turning off gopls formatting')
      caps.documentFormattingProvider = false
      caps.documentRangeFormattingProvider = false
    elseif client.name == 'null-ls' then
      caps.documentFormattingProvider = true
      caps.documentRangeFormattingProvider = true
    end
  end
end

M.mod_format = mod.format
M.make_comments = function()
  if fs.is_code_file(vim.fn.expand '%') or config.get('format', 'comments', 'test_files') then
    require('goldsmith.comment').make_comments(
      config.get('format', 'comments', 'template'),
      config.get('format', 'comments', 'private')
    )
  end
end

function M.lsp_format()
  vim.lsp.buf.format()
end

-- https://github.com/neovim/nvim-lspconfig/issues/115#issuecomment-902680058
function M.organize_imports(wait_ms)
  wait_ms = wait_ms or config.get('format', 'goimports', 'timeout')
  local params = vim.lsp.util.make_range_params()
  params.context = { only = { 'source.organizeImports' } }
  local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, wait_ms)
  for client_id, res in pairs(result or {}) do
    local client = vim.lsp.get_client_by_id(client_id)
    for _, r in pairs(res.result or {}) do
      if r.edit then
        vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding)
      end
    end
  end
end

return M
