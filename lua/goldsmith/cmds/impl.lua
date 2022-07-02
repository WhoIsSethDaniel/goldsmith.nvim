local buffer = require 'goldsmith.buffer'
local cmds = require 'goldsmith.lsp.commands'
local job = require 'goldsmith.job'
local config = require 'goldsmith.config'
local log = require 'goldsmith.log'

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
      table.insert(ifaces, string.format('%s.%s', pkg, m))
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

function M.run(args)
  local cfg = config.get 'goimpl' or {}

  local recv
  local iface
  local n = #args
  if n > 3 then
    log.error('Impl', 'Too many arguments. :GoImpl <recv> <iface>')
    return
  elseif n == 3 then
    iface = args[3]
    recv = string.format('%s %s', args[1], args[2])
  elseif n == 2 then
    iface = args[2]
    recv = args[1]
  else
    log.error('Impl', 'Too few arguments. :GoImpl <recv> <iface>')
    return
  end

  local out = ''
  local b = vim.api.nvim_get_current_buf()
  local cmd = { 'impl', "'" .. recv .. "'", iface }
  job.run(cmd, cfg, {
    stderr_buffered = true,
    stdout_buffered = true,
    on_stdout = function(id, data, name)
      out = data
    end,
    on_stderr = function(id, data, name)
      if data[1] ~= '' then
        local err = table.concat(data, '\n')
        vim.schedule(function()
          log.error('Impl', err)
        end)
      end
    end,
    on_exit = function(id, code, event)
      if code > 0 then
        return
      end
      local r, _ = unpack(vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_set_lines(b, r, r, false, out)
    end,
  })
end

return M
