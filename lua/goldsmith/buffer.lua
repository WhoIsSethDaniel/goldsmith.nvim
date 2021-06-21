local api = vim.api

-- 'current' is simply the most recent 'go' buffer to be created
local M = {
  all = {}
}

function M.buffer_checkin()
  M.current = api.nvim_get_current_buf()
  M.all[M.current] = M.current
end

-- return the most recent buffer if it is valid, otherwise just return any of the registered buffers
-- assuming it is valid
function M.get_valid_buffer()
  if M.current ~= nil and api.nvim_buf_is_valid(M.current) then
    return M.current
  end
  for buf, _ in ipairs(M.all) do
    -- maybe nvim_buf_is_loaded would be sufficient?
    if api.nvim_buf_is_valid(buf) then
      return buf
    else
      M.current[buf] = nil
    end
  end
end

return M
