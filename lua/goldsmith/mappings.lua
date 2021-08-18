local config = require 'goldsmith.config'
local log = require 'goldsmith.log'

local M = {}

local action_map = {
  definition = 'goto_definition',
  hover = 'hover',
  implementation = 'goto_implementation',
  signature_help = 'signature_help',
  add_workspace_folder = 'add_workspace_folder',
  remove_workspace_folder = 'remove_workspace_folder',
  list_workspace_folders = 'list_workspace_folders',
  type_definition = 'type_defintion',
  rename = 'rename',
  references = 'references',
  code_action = 'code_action',
  show_line_diagnostics = 'show_diagnostics',
  goto_previous_diagnostic = 'goto_previous_diagnostic',
  goto_next_diagnostic = 'goto_next_diagnostic',
  diagnostic_set_loclist = 'diag_set_loclist',
  format = 'format',
}

function M.set_buffer_mappings(b)
  if b == nil then
    log.error('Mapping', 'set_buffer_mappings() must be given a buffer number.')
    return
  end

  local ft = vim.opt.filetype:get()
  if ft ~= 'go' and ft ~= 'gomod' then
    return false
  end

  local function set_map(mode, km, action)
    if action == nil or action == '' then
      return
    end
    vim.api.nvim_buf_set_keymap(
      b,
      mode,
      km,
      string.format("<cmd>lua require'goldsmith.cmds.lsp'.%s()<cr>", action),
      { noremap = true, silent = true }
    )
  end

  local maps = config.get 'mappings'
  for k, act in pairs(maps) do
    set_map('n', k, action_map[act])
  end

  return true
end

return M
