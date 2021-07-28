local api = vim.api
local buffer = require 'goldsmith.buffer'
local config = require 'goldsmith.config'
local wb = require 'goldsmith.winbuf'
local job = require 'goldsmith.job'

local M = { buf_nr = -1 }

function M.complete(arglead, cmdline, cursorPos)
  local bnum = buffer.get_valid_buffer() or api.nvim_get_current_buf()
  local resp = vim.lsp.buf_request_sync(bnum, 'workspace/executeCommand', {
    command = 'gopls.list_known_packages',
    arguments = { { URI = vim.uri_from_bufnr(bnum) } },
  })
  local pkgs
  for _, response in pairs(resp) do
    if response.result ~= nil then
      pkgs = response.result.Packages
      break
    end
  end
  return table.concat(pkgs, '\n')
end

function M.run(...)
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
  cfg['stderr_buffered'] = true
  cfg['stdout_buffered'] = true
  cfg['on_stdout'] = function(id,data,name)
    out = data
  end
  cfg['on_stderr'] = function(id,data,name)
    local err = table.concat(data, "\n")
    vim.api.nvim_err_writeln(err)
  end
  cfg['on_exit'] = function(id,code,event)
    if code > 0 then
      return
    end

    local winbuf = wb.create_winbuf(cfg)
    M.buf_nr = winbuf.buf

    api.nvim_buf_set_option(winbuf.buf, 'filetype', 'godoc')
    api.nvim_buf_set_option(winbuf.buf, 'bufhidden', 'delete')
    api.nvim_buf_set_option(winbuf.buf, 'buftype', 'nofile')
    api.nvim_buf_set_option(winbuf.buf, 'swapfile', false)
    api.nvim_buf_set_option(winbuf.buf, 'buflisted', false)
    api.nvim_win_set_option(winbuf.win, 'cursorline', false)
    api.nvim_win_set_option(winbuf.win, 'cursorcolumn', false)
    api.nvim_win_set_option(winbuf.win, 'number', false)
    api.nvim_win_set_option(winbuf.win, 'relativenumber', false)
    api.nvim_win_set_option(winbuf.win, 'signcolumn', 'no')

    api.nvim_buf_set_option(winbuf.buf, 'modifiable', true)
    api.nvim_buf_set_lines(winbuf.buf, 0, -1, false, {})
    api.nvim_buf_set_lines(winbuf.buf, -1, -1, false, out)
    api.nvim_buf_set_option(winbuf.buf, 'modifiable', false)

    api.nvim_buf_set_keymap(winbuf.buf, '', '<CR>', ':<C-U>close<CR>', { silent = true, noremap = true })
    api.nvim_buf_set_keymap(winbuf.buf, '', 'q', ':<C-U>close<CR>', { silent = true, noremap = true })
    api.nvim_buf_set_keymap(winbuf.buf, '', '<Esc>', ':<C-U>close<CR>', { silent = true, noremap = true })
    api.nvim_buf_set_keymap(winbuf.buf, 'n', '<Esc>[', '<Esc>[', { silent = true, noremap = true })
  end
  job.run(string.format('go doc %s', args), cfg)
end

return M
