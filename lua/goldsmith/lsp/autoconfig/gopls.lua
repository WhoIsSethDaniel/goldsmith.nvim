-- see https://github.com/golang/tools/blob/master/gopls/doc/settings.md
-- for all settings for the most recent version of gopls;
-- see https://github.com/golang/tools/releases for a changelog
local util = require 'lspconfig.util'
local servers = require 'goldsmith.lsp.servers'
local plugins = require 'goldsmith.plugins'

local M = { _config = {} }

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

local set_default_capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- if the user wants to use postfixCompletions this is REQUIRED
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return capabilities
end

local set_default_command = function()
  return { servers.info('gopls').cmd, '-remote=auto' }
end

local DEFAULTS = {
  flags = {
    debounce_text_changes = 500,
  },
  settings = {
    gopls = CONFIG_DEFAULTS,
  },
}

-- debug options:
-- '-logfile=auto',
-- '-rpc.trace'
local set_command = function()
  return { servers.info('gopls').cmd, '-remote=auto' }
end

local set_filetypes = function(ft)
  local t = vim.tbl_values(ft or {})
  for _, filetype in ipairs(FILETYPES) do
    if not vim.tbl_contains(t, filetype) then
      table.insert(t, filetype)
    end
  end
  return t
end

local correct_server_conf_key = function()
  return servers.lsp_plugin_name 'gopls'
end

function M.has_config()
  if plugins.is_installed 'lspconfig' then
    return true
  end
  return false
end

function M.config()
  local server = correct_server_conf_key()
  require('lspconfig')[server].setup(M._config)
end

function M.setup(cf)
  M._config = cf or {}
  M._config['cmd'] = set_command(cf['cmd'] or {})
  M._config['filetypes'] = set_filetypes(cf['filetypes'] or {})
  M._config['flags'] = vim.tbl_extend('keep', cf['flags'] or {}, DEFAULTS.flags)
  M._config['settings'] = vim.tbl_deep_extend('keep', cf['settings'] or {}, DEFAULTS.settings)
  if cf['root_dir'] == nil then
    M._config['root_dir'] = set_root_dir()
  end
  if cf['capabilities'] == nil then
    M._config['capabilities'] = set_default_capabilities()
  end
  if cf['on_attach'] == nil then
    M._config['on_attach'] = on_attach
  end
end

return M
