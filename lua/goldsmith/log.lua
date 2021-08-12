local M = {}

function M.error(lvl, label, msg)
  if label then
    vim.api.nvim_err_writeln(string.format('Goldsmith: %s: %s', label, msg))
  else
    vim.api.nvim_err_writeln(string.format('Goldsmith: %s', msg))
  end
end

return M
