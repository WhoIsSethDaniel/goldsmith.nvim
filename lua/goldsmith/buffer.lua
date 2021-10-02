local config = require 'goldsmith.config'
local log = require 'goldsmith.log'

local M = {}

-- 'current' is simply the most recent 'go' buffer to have been used
local current
local all = {}

local default_action_map = {
  godef = { act = "<cmd>lua require'goldsmith.cmds.lsp'.goto_definition()<cr>", ft = { 'go' } },
  hover = { act = "<cmd>lua require'goldsmith.cmds.lsp'.hover()<cr>", ft = { 'go' } },
  goimplementation = { act = "<cmd>lua require'goldsmith.cmds.lsp'.goto_implementation()<cr>", ft = { 'go' } },
  sighelp = { act = "<cmd>lua require'goldsmith.cmds.lsp'.signature_help()<cr>", ft = { 'go' } },
  ['add-ws-folder'] = { act = "<cmd>lua require'goldsmith.cmds.lsp'.add_workspace_folder()<cr>", ft = '*' },
  ['rm-ws-folder'] = { act = "<cmd>lua require'goldsmith.cmds.lsp'.remove_workspace_folder()<cr>", ft = '*' },
  ['list-ws-folders'] = { act = "<cmd>lua require'goldsmith.cmds.lsp'.list_workspace_folders()<cr>", ft = '*' },
  typedef = { act = "<cmd>lua require'goldsmith.cmds.lsp'.type_definition()<cr>", ft = { 'go' } },
  rename = { act = "<cmd>lua require'goldsmith.cmds.lsp'.rename()<cr>", ft = { 'go' } },
  goref = { act = "<cmd>lua require'goldsmith.cmds.lsp'.references()<cr>", ft = { 'go' } },
  codeaction = { act = "<cmd>lua require'goldsmith.cmds.lsp'.code_action()<cr>", ft = '*' },
  showdiag = { act = "<cmd>lua require'goldsmith.cmds.lsp'.show_diagnostics()<cr>", ft = '*' },
  prevdiag = { act = "<cmd>lua require'goldsmith.cmds.lsp'.goto_previous_diagnostic()<cr>", ft = '*' },
  nextdiag = { act = "<cmd>lua require'goldsmith.cmds.lsp'.goto_next_diagnostic()<cr>", ft = '*' },
  setloclist = { act = "<cmd>lua require'goldsmith.cmds.lsp'.diag_set_loclist()<cr>", ft = '*' },
  format = { act = "<cmd>lua require'goldsmith.cmds.format'.run(1)<cr>", ft = '*' },
  ['toggle-debug-console'] = { act = "<cmd>lua require'goldsmith.log'.toggle_debug_console()<cr>", ft = '*' },
  ['test-close-window'] = { act = "<cmd>lua require'goldsmith.winbuf'.close_window('test')<cr>", ft = { 'go' } },
  ['test-last'] = { act = "<cmd>lua require'goldsmith.testing'.last()<cr>", ft = { 'go' } },
  ['test-visit'] = { act = "<cmd>lua require'goldsmith.testing'.visit()<cr>", ft = { 'go' } },
  ['test-nearest'] = { act = "<cmd>lua require'goldsmith.testing'.nearest()<cr>", ft = { 'go' } },
  ['test-suite'] = { act = "<cmd>lua require'goldsmith.testing'.suite()<cr>", ft = { 'go' } },
  ['test-pkg'] = { act = "<cmd>lua require'goldsmith.testing'.pkg()<cr>", ft = { 'go' } },
  ['test-b-nearest'] = { act = "<cmd>lua require'goldsmith.testing'.nearest({type='bench'})<cr>", ft = { 'go' } },
  ['test-b-suite'] = { act = "<cmd>lua require'goldsmith.testing'.suite({type='bench'})<cr>", ft = { 'go' } },
  ['test-b-pkg'] = { act = "<cmd>lua require'goldsmith.testing'.pkg({type='bench'})<cr>", ft = { 'go' } },
  ['test-a-nearest'] = { act = "<cmd>lua require'goldsmith.testing'.nearest({type='any'})<cr>", ft = { 'go' } },
  ['test-a-suite'] = { act = "<cmd>lua require'goldsmith.testing'.suite({type='any'})<cr>", ft = { 'go' } },
  ['test-a-pkg'] = { act = "<cmd>lua require'goldsmith.testing'.pkg({type='any'})<cr>", ft = { 'go' } },
  ['alt-file'] = { act = "<cmd>lua require'goldsmith.cmds.alt'.run()<cr>", ft = { 'go' } },
  ['alt-file-force'] = { act = "<cmd>lua require'goldsmith.cmds.alt'.run('!')<cr>", ft = { 'go' } },
  ['fillstruct'] = { act = "<cmd>lua require'goldsmith.cmds.fillstruct'.run(1000)<cr>", ft = { 'go' } },
  ['codelens-on'] = { act = "<cmd>lua require'goldsmith.cmds.lsp'.turn_on_codelens()<cr>", ft = '*' },
  ['codelens-off'] = { act = "<cmd>lua require'goldsmith.cmds.lsp'.turn_off_codelens()<cr>", ft = '*' },
  ['codelens-run'] = { act = "<cmd>lua require'goldsmith.cmds.lsp'.run_codelens()<cr>", ft = '*' },
  ['sym-highlight-on'] = { act = "<cmd>lua require'goldsmith.cmds.lsp'.turn_on_symbol_highlighting()<cr>", ft = { 'go' } },
  ['sym-highlight-off'] = {
    act = "<cmd>lua require'goldsmith.cmds.lsp'.turn_off_symbol_highlighting()<cr>",
    ft = { 'go' },
  },
  ['sym-highlight'] = { act = "<cmd>lua require'goldsmith.cmds.lsp'.highlight_current_symbol()<cr>", ft = { 'go' } },
  ['start-follow'] = { act = "<cmd>lua require'goldsmith.winbuf'.start_follow_buffer()<cr>" },
  ['stop-follow'] = { act = "<cmd>lua require'goldsmith.winbuf'.stop_follow_buffer()<cr>" },
  ['close-terminal'] = { act = "<cmd>lua require'goldsmith.winbuf'.close_window('job_terminal')<cr>", ft = '*' },
  ['build'] = { act = "<cmd>lua require'goldsmith.cmds.build'.run()<cr>", ft = '*' },
  ['run'] = { act = "<cmd>lua require'goldsmith.cmds.run'.run()<cr>", ft = '*' },
  ['build-last'] = { act = "<cmd>lua require'goldsmith.cmds.build'.last()<cr>", ft = '*' },
  ['run-last'] = { act = "<cmd>lua require'goldsmith.cmds.run'.last()<cr>", ft = '*' },
  ['close-any'] = { act = "<cmd>lua require'goldsmith.winbuf'.close_any_window(false)<cr>", ft = '*' },
  ['super-close-any'] = { act = "<cmd>lua require'goldsmith.winbuf'.close_any_window(true)<cr>", ft = '*' },
  ['coverage'] = { act = "<cmd>lua require'goldsmith.cmds.coverage'.run({bang='<bang>',type='job'})<cr>", ft = { 'go' } },
  ['coverage-browser'] = {
    act = "<cmd>lua require'goldsmith.cmds.coverage'.run({bang='<bang>',type='web'})<cr>",
    ft = { 'go' },
  },
  ['coverage-on'] = { act = "<cmd>lua require'goldsmith.cmds.coverage'.on()<cr>", ft = { 'go' } },
  ['coverage-off'] = { act = "<cmd>lua require'goldsmith.cmds.coverage'.off()<cr>", ft = { 'go' } },
  ['coverage-files'] = { act = "<cmd>lua require'goldsmith.cmds.coverage'.show_files()<cr>", ft = { 'go' } },
  ['tostruct'] = { act = ':GoToStruct<cr>', ft = { 'go' }, m = { 'v', 'n' } },
  ['tostructreg'] = { act = ':GoToStructReg<cr>', ft = { 'go' }, m = { 'v', 'n' } },
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
function M.set_buffer_map(buf, mode, name, user_act, opts)
  local act = user_act or default_action_map[name].act
  local maps = config.get_mapping(name)
  for _, km in ipairs(maps) do
    vim.api.nvim_buf_set_keymap(buf, mode, km, act, opts or {})
  end
end

function M.set_buffer_keymaps(buf)
  local function set_map(name, modes, maps, action, opts)
    local plug = string.format('<Plug>(goldsmith-%s)', name)
    for _, mode in ipairs(modes) do
      vim.api.nvim_buf_set_keymap(buf, mode, plug, action, opts)
    end
    for _, km in ipairs(maps) do
      for _, mode in ipairs(modes) do
        vim.api.nvim_buf_set_keymap(buf, mode, km, plug, {})
      end
    end
  end

  local ft = vim.opt.filetype:get()
  local opts = { noremap = true, silent = true }
  for name, d in pairs(default_action_map) do
    local maps = config.get_mapping(name)
    if d.ft and (d.ft == '*' or vim.tbl_contains(d.ft, ft)) then
      set_map(name, d.m or { 'n' }, maps, d.act, opts)
    end
  end

  return true
end

function M.is_managed_buffer()
  local b = vim.api.nvim_get_current_buf()
  if all[b] ~= nil then
    return true
  end
  return false
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

  M.set_buffer_keymaps(b)
end

return M
