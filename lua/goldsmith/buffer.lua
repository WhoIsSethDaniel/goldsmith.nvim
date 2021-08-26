local config = require 'goldsmith.config'

-- 'current' is simply the most recent 'go' buffer to have been used
local M = {
  all = {},
}

local default_mappings = {
  ['gd'] = 'goto_definition',
  ['<C-]>'] = 'goto_definition',
  ['K'] = 'hover',
  ['gi'] = 'goto_implementation',
  ['<C-k>'] = 'signature_help',
  ['<leader>wa'] = 'add_workspace_folder',
  ['<leader>wr'] = 'remove_workspace_folder',
  ['<leader>wl'] = 'list_workspace_folders',
  ['<leader>D'] = 'type_definition',
  ['<leader>rn'] = 'rename',
  ['<leader>gr'] = 'references',
  ['<leader>ca'] = 'code_action',
  ['<leader>e'] = 'show_diagnostics',
  ['[d'] = 'goto_previous_diagnostic',
  [']d'] = 'goto_next_diagnostic',
  ['<leader>q'] = 'diagnostic_set_loclist',
  ['<leader>f'] = 'format',
}

function M.checkin()
  M.current = vim.api.nvim_get_current_buf()
  M.all[M.current] = M.current
end

-- return the most recent buffer if it is valid, otherwise just return any of the registered buffers
-- assuming it is valid
function M.get_valid_buffer()
  if M.current ~= nil and vim.api.nvim_buf_is_valid(M.current) then
    return M.current
  end
  for _, buf in pairs(M.all) do
    -- maybe nvim_buf_is_loaded would be sufficient?
    if vim.api.nvim_buf_is_valid(buf) then
      return buf
    else
      M.all[buf] = nil
    end
  end
end

function M.set_buffer_options()
  local omni = config.get('completion', 'omni')
  if omni then
    M.set_omnifunc()
  end

  local enable_mappings = config.get('mappings', 'enable')
  if enable_mappings then
    M.set_buffer_mappings()
  end
end

function M.set_omnifunc()
  vim.api.nvim_buf_set_option(vim.api.nvim_get_current_buf(), 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

function M.set_buffer_mappings()
  local function set_map(mode, km, action)
    if action == nil or action == '' then
      return
    end
    vim.api.nvim_buf_set_keymap(
      vim.api.nvim_get_current_buf(),
      mode,
      km,
      string.format("<cmd>lua require'goldsmith.cmds.lsp'.%s()<cr>", action),
      { noremap = true, silent = true }
    )
  end

  for k, act in pairs(default_mappings) do
    set_map('n', k, act)
  end

  return true
end


return M
