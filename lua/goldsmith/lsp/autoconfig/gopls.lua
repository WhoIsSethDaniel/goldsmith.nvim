-- see https://github.com/golang/tools/blob/master/gopls/doc/settings.md
-- for all settings for the most recent version of gopls;
-- see https://github.com/golang/tools/releases for a changelog
local util = require 'lspconfig.util'
local servers = require 'goldsmith.lsp.servers'

local M = {}

local CONFIG_DEFAULTS = {
  gofumpt = true,
  staticcheck = true,
}

local FILETYPES = { 'go', 'gomod' }

-- currently this is mostly the lspconfig defaults;
-- should mutate over time to be better
local on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(
    bufnr,
    'n',
    '<leader>wl',
    '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
    opts
  )
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  if client.resolved_capabilities.document_formatting then
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting_seq_sync()<CR>', opts)
  elseif client.resolved_capabilities.document_range_formatting then
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>f', '<cmd>lua vim.lsp.buf.range_formatting()<CR>', opts)
  end
end

local set_root_dir = function()
  return util.root_pattern('go.mod', '.git')
end

local set_filetypes = function()
  return FILETYPES
end

local set_capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- if the user wants to use postfixCompletions this is REQUIRED
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return capabilities
end

-- debug options:
-- '-logfile=auto',
-- '-rpc.trace'
local set_command = function()
  return { servers.info('gopls').cmd, '-remote=auto' }
end

local defaults = function()
  return {
    cmd = set_command(),
    capabilities = set_capabilities(),
    on_attach = on_attach,
    root_dir = set_root_dir(),
    filetypes = set_filetypes(),
    flags = {
      debounce_text_changes = 500,
    },
    settings = {
      gopls = CONFIG_DEFAULTS,
    },
  }
end

local correct_server_conf_key = function()
  return servers.lsp_plugin_name 'gopls'
end

function M.config()
  if M._config == nil then
    return
  end
  local server = correct_server_conf_key()
  require('lspconfig')[server].setup(vim.tbl_deep_extend('keep', M._config, defaults()))
end

function M.setup(lsp_config)
  M._config = lsp_config or {}
end

return M
