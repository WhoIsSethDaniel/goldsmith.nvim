local config = require 'goldsmith.config'

local M = {}

-- 'current' is simply the most recent 'go' buffer to have been used
local current
local all = {}

local default_action_map = {
  godef = { act = "require'goldsmith.cmds.lsp'.goto_definition()" },
  hover = { act = "require'goldsmith.cmds.lsp'.hover()" },
  goimplementation = { act = "require'goldsmith.cmds.lsp'.goto_implementation()" },
  sighelp = { act = "require'goldsmith.cmds.lsp'.signature_help()" },
  ['add-ws-folder'] = { act = "require'goldsmith.cmds.lsp'.add_workspace_folder()" },
  ['rm-ws-folder'] = { act = "require'goldsmith.cmds.lsp'.remove_workspace_folder()" },
  ['list-ws-folders'] = { act = "require'goldsmith.cmds.lsp'.list_workspace_folders()" },
  typedef = { act = "require'goldsmith.cmds.lsp'.type_definition()" },
  rename = { act = "require'goldsmith.cmds.lsp'.rename()" },
  goref = { act = "require'goldsmith.cmds.lsp'.references()" },
  codeaction = { act = "require'goldsmith.cmds.lsp'.code_action()" },
  showdiag = { act = "require'goldsmith.cmds.lsp'.show_diagnostics()" },
  prevdiag = { act = "require'goldsmith.cmds.lsp'.goto_previous_diagnostic()" },
  nextdiag = { act = "require'goldsmith.cmds.lsp'.goto_next_diagnostic()" },
  setloclist = { act = "require'goldsmith.cmds.lsp'.diagnostic_set_loclist()" },
  format = { act = "require'goldsmith.cmds.format'.run(1)" },
  ['toggle-debug-console'] = { act = "require'goldsmith.log'.toggle_debug_console()" },
  ['test-close-window'] = { act = "require'goldsmith.testing'.close_window()" },
  ['test-last'] = { act = "require'goldsmith.testing'.last()" },
  ['test-nearest'] = { act = "require'goldsmith.testing'.nearest()" },
  ['test-visit'] = { act = "require'goldsmith.testing'.visit()" },
  ['test-suite'] = { act = "require'goldsmith.testing'.suite()" },
  ['test-pkg'] = { act = "require'goldsmith.testing'.pkg()" },
}

function M.checkin()
  current = vim.api.nvim_get_current_buf()
  all[current] = current
end

-- return the most recent buffer if it is valid, otherwise just return any of the registered buffers
-- assuming it is valid
function M.get_valid_buffer()
  if current ~= nil and vim.api.nvim_buf_is_valid(M.current) then
    return current
  end
  for _, buf in pairs(all) do
    -- maybe nvim_buf_is_loaded would be sufficient?
    if vim.api.nvim_buf_is_valid(buf) then
      return buf
    else
      all[buf] = nil
    end
  end
end

function M.set_buffer_options()
  local b = vim.api.nvim_get_current_buf()

  local omni = config.get('completion', 'omni')
  if omni then
    M.set_omnifunc(b)
  end

  local enable_mappings = config.get('mappings', 'enable')
  M.set_buffer_keymaps(b, enable_mappings)
end

function M.set_omnifunc(b)
  vim.api.nvim_buf_set_option(b, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

function M.set_buffer_keymaps(buf, use_defaults)
  local function set_map(name, mode, maps, action, opts)
    if action == nil or action == '' then
      return
    end
    local plug = string.format('<Plug>(goldsmith-%s)', name)
    vim.api.nvim_buf_set_keymap(buf, mode, plug, string.format('<cmd>lua %s<cr>', action), opts)
    for _, km in ipairs(maps) do
      vim.api.nvim_buf_set_keymap(buf, mode, km, plug, {})
    end
  end

  local user_maps = config.get 'mappings'
  local opts = { noremap = true, silent = true }
  for name, d in pairs(default_action_map) do
    set_map(name, 'n', user_maps[name], d.act, opts)
  end

  return true
end

return M
