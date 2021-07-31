local buffer = require 'goldsmith.buffer'
local cmds = require 'goldsmith.lsp.cmds'
local job = require 'goldsmith.job'
local config = require 'goldsmith.config'

local M = {}

local function match_partial_iface_name(part)
  local pkg, iface = string.match(part, '^(.*)%.(.*)$')

  local cmd = string.format('go doc %s', pkg)
  local doc = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    return
  end

  local ifaces = {}
  local pat = string.format('^type (%s.*) interface', iface)
  for _, line in ipairs(doc) do
    local m = string.match(line, pat)
    if m ~= nil then
      table.insert(ifaces, string.format("%s.%s", pkg, m))
    end
  end
  return table.concat(ifaces, '\n')
end

function M.complete(arglead, cmdline, cursorPos)
  local words = vim.split(cmdline, '%s+')
  if #words < 3 or #words > 4 then
    return ''
  end

  local last = words[#words]
  if string.match(last, '^.+%..*') ~= nil then
    local part = match_partial_iface_name(last)
    if part ~= nil then
      return part
    end
  end

  local bnum = buffer.get_valid_buffer() or vim.api.nvim_get_current_buf()
  local pkgs = cmds.list_known_packages(bnum)
  return table.concat(pkgs, '\n')
end

function M.run(...)
  local cfg = config.get 'goimpl' or {}

  local recv
  local iface
  local args = { ... }
  local n = #args
  if n > 3 then
    vim.api.nvim_err_writeln 'Too many arguments. :GoImpl <recv> <iface>'
    return
  elseif n == 3 then
    iface = args[3]
    recv = string.format('%s %s', args[1], args[2])
  elseif n == 2 then
    iface = args[2]
    recv = args[1]
  else
    vim.api.nvim_err_writeln 'Too few arguments. :GoImpl <recv> <iface>'
    return
  end

  local b
  local out = ''
  cfg['stderr_buffered'] = true
  cfg['stdout_buffered'] = true
  cfg['on_stdout'] = function(id, data, name)
    out = data
  end
  cfg['on_stderr'] = function(id, data, name)
    local err = table.concat(data, '\n')
    vim.api.nvim_err_write(err)
  end
  cfg['on_exit'] = function(id, code, event)
    if code > 0 then
      return
    end
    local r, _ = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_lines(b, r, r, false, out)
  end
  b = vim.api.nvim_get_current_buf()
  job.run(string.format("impl '%s' %s", recv, iface), cfg)
end

return M
