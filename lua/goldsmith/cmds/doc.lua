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

function M.run(type, ...)
  local cmd_cfg = config.get 'godoc' or {}
  local window_cfg = config.get 'window'
  local cfg = vim.tbl_deep_extend(
    'force',
    window_cfg,
    cmd_cfg,
    { create = true, title = '[Go Documentation]', reuse = M.buf_nr }
  )

  local args = ''
  for _, a in ipairs { ... } do
    args = args .. ' ' .. a
  end
  local out = ''
  job.run(
    string.format('go %s %s', type, args),
    vim.tbl_deep_extend('force', cfg, {
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

        vim.api.nvim_buf_set_option(winbuf.buf, 'filetype', 'godoc')
        vim.api.nvim_buf_set_option(winbuf.buf, 'bufhidden', 'delete')
        vim.api.nvim_buf_set_option(winbuf.buf, 'buftype', 'nofile')
        vim.api.nvim_buf_set_option(winbuf.buf, 'swapfile', false)
        vim.api.nvim_buf_set_option(winbuf.buf, 'buflisted', false)
        vim.api.nvim_win_set_option(winbuf.win, 'cursorline', false)
        vim.api.nvim_win_set_option(winbuf.win, 'cursorcolumn', false)
        vim.api.nvim_win_set_option(winbuf.win, 'number', false)
        vim.api.nvim_win_set_option(winbuf.win, 'relativenumber', false)
        vim.api.nvim_win_set_option(winbuf.win, 'signcolumn', 'no')

        vim.api.nvim_buf_set_option(winbuf.buf, 'modifiable', true)
        vim.api.nvim_buf_set_lines(winbuf.buf, 0, -1, false, {})
        vim.api.nvim_buf_set_lines(winbuf.buf, -1, -1, false, out)
        vim.api.nvim_buf_set_option(winbuf.buf, 'modifiable', false)

        vim.api.nvim_buf_set_keymap(winbuf.buf, '', '<CR>', ':<C-U>close<CR>', { silent = true, noremap = true })
        vim.api.nvim_buf_set_keymap(winbuf.buf, '', 'q', ':<C-U>close<CR>', { silent = true, noremap = true })
        vim.api.nvim_buf_set_keymap(winbuf.buf, '', '<Esc>', ':<C-U>close<CR>', { silent = true, noremap = true })
        vim.api.nvim_buf_set_keymap(winbuf.buf, 'n', '<Esc>[', '<Esc>[', { silent = true, noremap = true })
      end,
    })
  )
end

return M
