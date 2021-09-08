local config = require 'goldsmith.config'
local log = require 'goldsmith.log'

local M = {}

-- 'current' is simply the most recent 'go' buffer to have been used
local current
local all = {}

local default_action_map = {
  godef = { act = "require'goldsmith.cmds.lsp'.goto_definition()", ft = { 'go' } },
  hover = { act = "require'goldsmith.cmds.lsp'.hover()", ft = { 'go' } },
  goimplementation = { act = "require'goldsmith.cmds.lsp'.goto_implementation()", ft = { 'go' } },
  sighelp = { act = "require'goldsmith.cmds.lsp'.signature_help()", ft = { 'go' } },
  ['add-ws-folder'] = { act = "require'goldsmith.cmds.lsp'.add_workspace_folder()", ft = '*' },
  ['rm-ws-folder'] = { act = "require'goldsmith.cmds.lsp'.remove_workspace_folder()", ft = '*' },
  ['list-ws-folders'] = { act = "require'goldsmith.cmds.lsp'.list_workspace_folders()", ft = '*' },
  typedef = { act = "require'goldsmith.cmds.lsp'.type_definition()", ft = { 'go' } },
  rename = { act = "require'goldsmith.cmds.lsp'.rename()", ft = { 'go' } },
  goref = { act = "require'goldsmith.cmds.lsp'.references()", ft = { 'go' } },
  codeaction = { act = "require'goldsmith.cmds.lsp'.code_action()", ft = '*' },
  showdiag = { act = "require'goldsmith.cmds.lsp'.show_diagnostics()", ft = '*' },
  prevdiag = { act = "require'goldsmith.cmds.lsp'.goto_previous_diagnostic()", ft = '*' },
  nextdiag = { act = "require'goldsmith.cmds.lsp'.goto_next_diagnostic()", ft = '*' },
  setloclist = { act = "require'goldsmith.cmds.lsp'.diagnostic_set_loclist()", ft = '*' },
  format = { act = "require'goldsmith.cmds.format'.run(1)", ft = '*' },
  ['toggle-debug-console'] = { act = "require'goldsmith.log'.toggle_debug_console()", ft = '*' },
  ['test-close-window'] = { act = "require'goldsmith.testing'.close_window()", ft = { 'go' } },
  ['test-last'] = { act = "require'goldsmith.testing'.last()", ft = { 'go' } },
  ['test-nearest'] = { act = "require'goldsmith.testing'.nearest()", ft = { 'go' } },
  ['test-visit'] = { act = "require'goldsmith.testing'.visit()", ft = { 'go' } },
  ['test-suite'] = { act = "require'goldsmith.testing'.suite()", ft = { 'go' } },
  ['test-pkg'] = { act = "require'goldsmith.testing'.pkg()", ft = { 'go' } },
  ['alt-file'] = { act = "require'goldsmith.cmds.alt'.run()", ft = { 'go' } },
  ['alt-file-force'] = { act = "require'goldsmith.cmds.alt'.run('!')", ft = { 'go' } },
  ['fillstruct'] = { act = "require'goldsmith.cmds.fillstruct'.run(1000)", ft = { 'go' } },
  ['codelens-on'] = { act = "require'goldsmith.cmds.lsp'.turn_on_codelens()", ft = '*' },
  ['codelens-off'] = { act = "require'goldsmith.cmds.lsp'.turn_off_codelens()", ft = '*' },
  ['codelens-run'] = { act = "require'goldsmith.cmds.lsp'.run_codelens()", ft = '*' },
  ['sym-highlight-on'] = { act = "require'goldsmith.cmds.lsp'.turn_on_symbol_highlighting()", ft = { 'go' } },
  ['sym-highlight-off'] = { act = "require'goldsmith.cmds.lsp'.turn_off_symbol_highlighting()", ft = { 'go' } },
  ['sym-highlight'] = { act = "require'goldsmith.cmds.lsp'.highlight_current_symbol()", ft = { 'go' } },
}

function M.checkin(b)
  current = b
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

function M.set_project_root()
  local rootdir = require('lspconfig.util').root_pattern(unpack(config.get('system', 'root_dir')))(vim.fn.expand '%:p')
    or vim.fn.expand '%:p:h'
  vim.cmd(string.format('lcd %s', rootdir))
  log.debug('Autoconfig', string.format('root dir: %s', rootdir))
  return rootdir
end

function M.set_omnifunc(b)
  vim.api.nvim_buf_set_option(b, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

-- for use in non-go related buffers
function M.set_buffer_map(buf, mode, name, act, opts)
  local maps = config.get('mappings', name)
  for _, km in ipairs(maps) do
    vim.api.nvim_buf_set_keymap(buf, mode, km, act, opts or {})
  end
end

function M.set_buffer_keymaps(buf, use_defaults)
  local function set_map(name, mode, maps, action, opts)
    local plug = string.format('<Plug>(goldsmith-%s)', name)
    vim.api.nvim_buf_set_keymap(buf, mode, plug, string.format('<cmd>lua %s<cr>', action), opts)
    for _, km in ipairs(maps) do
      vim.api.nvim_buf_set_keymap(buf, mode, km, plug, {})
    end
  end

  local ft = vim.opt.filetype:get()
  local user_maps = config.get 'mappings'
  local opts = { noremap = true, silent = true }
  for name, d in pairs(default_action_map) do
    if d.ft == '*' or vim.tbl_contains(d.ft, ft) then
      set_map(name, 'n', user_maps[name], d.act, opts)
    end
  end

  return true
end

function M.setup()
  local b = vim.api.nvim_get_current_buf()

  M.checkin(b)

  if not pcall(M.set_project_root) then
    log.error('Autoconfig', 'Failed to set project root. Is lspconfig installed?')
  end

  local omni = config.get('completion', 'omni')
  if omni then
    M.set_omnifunc(b)
  end

  M.set_buffer_keymaps(b, config.get('mappings', 'enable'))
end

return M
