local config = require 'goldsmith.config'

local M = {}

local default_keymaps = {
  godef = { maps = { 'gd', '<C-]>' }, act = "require'goldsmith.cmds.lsp'.goto_definition()" },
  hover = { maps = { 'K' }, act = "require'goldsmith.cmds.lsp'.hover()" },
  goimplementation = { maps = { 'gi' }, act = "require'goldsmith.cmds.lsp'.goto_implementation()" },
  sighelp = { maps = { '<C-k>' }, act = "require'goldsmith.cmds.lsp'.signature_help()" },
  ['add-ws-folder'] = { maps = { '<leader>wa' }, act = "require'goldsmith.cmds.lsp'.add_workspace_folder()" },
  ['rm-ws-folder'] = { maps = { '<leader>wr' }, act = "require'goldsmith.cmds.lsp'.remove_workspace_folder()" },
  ['list-ws-folders'] = { maps = { '<leader>wl' }, act = "require'goldsmith.cmds.lsp'.list_workspace_folders()" },
  typedef = { maps = { '<leader>D' }, act = "require'goldsmith.cmds.lsp'.type_definition()" },
  rename = { maps = { '<leader>rn' }, act = "require'goldsmith.cmds.lsp'.rename()" },
  goref = { maps = { 'gr' }, act = "require'goldsmith.cmds.lsp'.references()" },
  codeaction = { maps = { '<leader>ca' }, act = "require'goldsmith.cmds.lsp'.code_action()" },
  showdiag = { maps = { '<leader>e' }, act = "require'goldsmith.cmds.lsp'.show_diagnostics()" },
  prevdiag = { maps = { '[d' }, act = "require'goldsmith.cmds.lsp'.goto_previous_diagnostic()" },
  nextdiag = { maps = { ']d' }, act = "require'goldsmith.cmds.lsp'.goto_next_diagnostic()" },
  setloclist = { maps = { '<leader>q' }, act = "require'goldsmith.cmds.lsp'.diagnostic_set_loclist()" },
  format = { maps = { '<leader>f' }, act = "require'goldsmith.cmds.format'.run(1)" },
  ['toggle-debug-console'] = { maps = { '<leader>dc' }, act = "require'goldsmith.log'.toggle_debug_console()" },
  ['test-close-window'] = { maps = { '<leader>tc' }, act = "require'goldsmith.testing'.close_window()" },
  ['test-last'] = { maps = { '<leader>tl' }, act = "require'goldsmith.testing'.last()" },
  ['test-nearest'] = { maps = { '<leader>tn' }, act = "require'goldsmith.testing'.nearest()" },
  ['test-visit'] = { maps = { '<leader>tv' }, act = "require'goldsmith.testing'.visit()" },
  ['test-suite'] = { maps = { '<leader>ts' }, act = "require'goldsmith.testing'.suite()" },
  ['test-pkg'] = { maps = { '<leader>tp' }, act = "require'goldsmith.testing'.pkg()" },
}

function M.add_default_keymaps(maps)
  default_keymaps = vim.tbl_deep_extend('error', default_keymaps, maps)
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
  for name, d in pairs(default_keymaps) do
    if user_maps[name] then
      if not vim.tbl_isempty(user_maps[name]) then
        set_map(name, 'n', user_maps[name], d.act, opts)
      end
    elseif use_defaults then
      set_map(name, 'n', d.maps, d.act, opts)
    end
  end

  return true
end

return M
