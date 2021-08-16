local M = {}

local levels = { 'error', 'info', 'debug' }
local real = true

local function error(label, msg)
  if label then
    vim.api.nvim_err_writeln(string.format('Goldsmith: %s: %s', label, msg))
  else
    vim.api.nvim_err_writeln(string.format('Goldsmith: %s', msg))
  end
end

local function info(label, msg)
end

local function debug(label, msg)
end

local function set(c)
  if c or (c == nil and real) then
    real = false
    M.error = error
    M.info = info
    M.debug = debug
  else
    real = true
    M.error = error
    M.info = function()end
    M.debug = function()end
  end
end
set()

return M
