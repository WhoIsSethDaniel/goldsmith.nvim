local log = require 'goldsmith.log'

local M = {}

do
  local all_methods = {
    'hide',
    'show',
    'get',
    'setloclist',
    'get_virt_text_chunks',
    'set',
    'setqflist',
    'disable',
    'enable',
    'get_next',
    'get_next_pos',
    'get_prev',
    'get_prev_pos',
    'goto_next',
    'goto_prev',
    'reset',
    'setloclist',
    'setqflist',
    'show_line_diagnostics',
    'show_position_diagnostics',
  }
  local method_lookup = {
    ['vim.lsp.diagnostic'] = {
      hide = { 'clear' },
      -- show = { 'redraw', 'display' },
      show = { 'display' },
      -- get = { 'get_all', 'get_count', 'get_line_diagnostics' },
      get = { 'get_line_diagnostics' },
      setloclist = { 'set_loclist' },
      get_virt_text_chunks = { 'get_virtual_text_chunks_for_line' },
      set = { 'save' },
      setqflist = { 'set_qflist' },
      open_float = { 'show_line_diagnostics' },
    },
  }

  do
    local ok, d = pcall(require, 'vim.diagnostic')
    if ok then
      return d
    end
  end

  do
    local ok, mod = pcall(require, 'vim.lsp.diagnostic')
    if not ok then
      log.error('Setup', 'Cannot determine correct LSP diagnostic module. Is this Neovim >= 0.5.0?')
      return
    end
    local mlookup = method_lookup['vim.lsp.diagnostic']
    for _, m in ipairs(all_methods) do
      if mlookup[m] ~= nil then
        M[m] = mod[mlookup[m][1]]
      else
        M[m] = mod[m]
      end
    end
  end
end

return M
