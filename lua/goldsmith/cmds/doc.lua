local buffer = require 'goldsmith.buffer'
local config = require 'goldsmith.config'
local wb = require 'goldsmith.winbuf'
local job = require 'goldsmith.job'
local cmds = require 'goldsmith.lsp.commands'

local M = { buf_nr = -1 }

function M.help_complete(arglead, cmdline, cursorPos)
  local doc = vim.fn.systemlist 'go help'
  if vim.v.shell_error ~= 0 then
    return
  end

  local items = {}
  for _, line in ipairs(doc) do
    local m = string.match(line, '^%s+([%w%p]+)')
    if m ~= nil and m ~= 'go' then
      table.insert(items, m)
    end
  end
  table.sort(items)
  return table.concat(items, '\n')
end

local function match_partial_item_name(pkg, part)
  local cmd = string.format('go doc %s', pkg)
  local doc = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    return
  end

  local items = {}
  for _, lead in ipairs { 'type', 'func', 'var', 'const' } do
    local pat = string.format('^%s (%s%%w+)', lead, part)
    for _, line in ipairs(doc) do
      local m = string.match(line, pat)
      if m ~= nil then
        table.insert(items, m)
      end
    end
  end
  table.sort(items)
  return table.concat(items, '\n')
end

function M.doc_complete(arglead, cmdline, cursorPos)
  local words = vim.split(cmdline, '%s+')
  if #words > 2 and string.match(words[#words - 1], '^-') == nil then
    local pkg = words[#words - 1]
    local item = words[#words]
    return match_partial_item_name(pkg, item)
  elseif #words > 1 and string.match(words[#words], '^-') == nil then
    local bnum = buffer.get_valid_buffer() or vim.api.nvim_get_current_buf()
    local pkgs = cmds.list_known_packages(bnum)
    return table.concat(pkgs, '\n')
  end
end

function M.run(type, args)
  local cfg = config.window_opts('godoc', { create = true, title = '[Go Documentation]', reuse = M.buf_nr })
  local out = ''
  job.run(string.format('go %s %s', type, table.concat(args, ' ')), cfg, {
    stderr_buffered = true,
    stdout_buffered = true,
    on_stdout = function(id, data, name)
      out = data
    end,
    on_stderr = function(id, data, name)
      local err = ''
      for _, e in ipairs(data) do
        if string.match(e, '^exit status') == nil and e ~= '' then
          err = err .. e
        end
      end
    end,
    on_exit = function(id, code, event)
      if code > 0 then
        return
      end

      local winbuf = wb.create_winbuf(cfg)
      M.buf_nr = winbuf.buf

      wb.make_buffer_plain(winbuf.buf, winbuf.win, { ft = 'godoc' })
      wb.clear_buffer(winbuf.buf)
      wb.append_to_buffer(winbuf.buf, out)

      vim.api.nvim_buf_set_keymap(winbuf.buf, '', '<CR>', ':<C-U>close!<CR>', { silent = true, noremap = true })
      vim.api.nvim_buf_set_keymap(winbuf.buf, '', 'q', ':<C-U>close!<CR>', { silent = true, noremap = true })
    end,
  })
end

return M
