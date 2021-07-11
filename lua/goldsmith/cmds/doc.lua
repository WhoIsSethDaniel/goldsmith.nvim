local api = vim.api
local buffer = require'goldsmith.buffer'
local lsp_util = require'goldsmith.lsp.utils'
local config = require'goldsmith.config'

local M = { buf_nr = -1 }

local function goenv(envname)
  local f = io.popen("go env " .. string.upper(envname))
  local val = f:lines()()
  f:close()
  return val
end

local function godoc(...)
  local args = ''
  for _, a in ipairs { ... } do
    args = args .. ' ' .. a
  end
  local f = io.popen(string.format("go doc %s", args))
  local content = f:lines('a')()
  f:close()
  return content
end

function M.complete(arglead, cmdline, cursorPos)
  local bnum = buffer.get_valid_buffer() or api.nvim_get_current_buf()
  local resp = vim.lsp.buf_request_sync(bnum, 'workspace/executeCommand', {
    command = "gopls.list_known_packages",
    arguments = { { URI = vim.uri_from_bufnr(bnum) } }
  })
  local pkgs
  for _, response in pairs(resp) do
    if response.result ~= nil then
      pkgs = response.result.Packages
      break
    end
  end
  return table.concat(pkgs, "\n")
end

function M.run(...)
  local doc = godoc(...)

  local open_split = 'split'
  local open_new = 'new'
  if config.get('godoc').open_split == 'vertical' then
    open_new = 'vnew'
    open_split = 'vsplit'
  end

  -- Much of the below is taken from vim-go's code, and
  -- translated to Lua
  if (M.buf_nr == -1) then
    vim.cmd(open_new)
    M.buf_nr = api.nvim_get_current_buf()
    api.nvim_buf_set_name(M.buf_nr, "[Go Documentation]")
  elseif vim.fn.bufwinnr(M.buf_nr) == -1 then
    vim.cmd(open_split)
    api.nvim_win_set_buf(0, M.buf_nr)
  elseif vim.fn.bufwinnr(M.buf_nr) ~= vim.fn.bufwinnr('%') then
    vim.cmd(vim.fn.bufwinnr(M.buf_nr) .. 'wincmd w')
  end

  api.nvim_buf_set_option(0, 'filetype', 'godoc')
  api.nvim_buf_set_option(0, 'bufhidden', 'delete')
  api.nvim_buf_set_option(0, 'buftype', 'nofile')
  api.nvim_buf_set_option(0, 'swapfile', false)
  api.nvim_buf_set_option(0, 'buflisted', false)
  api.nvim_win_set_option(0, 'cursorline', false)
  api.nvim_win_set_option(0, 'cursorcolumn', false)
  api.nvim_win_set_option(0, 'number', false)
  api.nvim_win_set_option(0, 'relativenumber', false)
  api.nvim_win_set_option(0, 'signcolumn', 'no')

  vim.cmd([[
        setlocal modifiable
        %delete _
    ]])
  api.nvim_buf_set_lines(M.buf_nr, -1, -1, false, vim.split(doc, "\n"))
  vim.cmd([[
        silent $delete _
        setlocal nomodifiable
        silent normal! gg
    ]])
  vim.cmd([[
        noremap <buffer> <silent> <CR> :<C-U>close<CR>
        noremap <buffer> <silent> q :<C-U>close<CR>
        noremap <buffer> <silent> <Esc> :<C-U>close<CR>
        nnoremap <buffer> <silent> <Esc>[ <Esc>[
    ]])
end

return M
