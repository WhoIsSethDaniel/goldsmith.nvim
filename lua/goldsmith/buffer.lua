local config = require 'goldsmith.config'
local km = require 'goldsmith.keymaps'

-- 'current' is simply the most recent 'go' buffer to have been used
local M = {
  all = {},
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
  local b = vim.api.nvim_get_current_buf()

  local omni = config.get('completion', 'omni')
  if omni then
    M.set_omnifunc(b)
  end

  local enable_mappings = config.get('mappings', 'enable')
  km.set_buffer_keymaps(b, enable_mappings)
end

function M.set_omnifunc(b)
  vim.api.nvim_buf_set_option(b, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

return M
