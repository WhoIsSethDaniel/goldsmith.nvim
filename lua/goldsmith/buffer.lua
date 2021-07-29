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

return M
