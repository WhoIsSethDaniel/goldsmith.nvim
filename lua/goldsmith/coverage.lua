local go = require 'goldsmith.go'

local M = {}

function M.highlight_on(buf, pf)
  local ns = vim.api.nvim_create_namespace 'go-coverage'
  local lc = vim.api.nvim_buf_line_count(buf)
  for i = 0, lc do
    vim.api.nvim_buf_add_highlight(buf, ns, 'goCoverageNormal', i, 0, -1)
  end
  local mod = go.module_path()
  if mod == nil then
    log.warn('Coverage', 'Cannot determine import path for current project.')
    mod = ''
  end
  local f = io.open(pf)
  for line in f:lines() do
    local m, bl, bc, el, ec, _, t = string.match(line, '^(.*):(%d+)%.(%d+),(%d+)%.(%d+)%s+(%d+)%s+(%d+)$')
    if m ~= nil then
      local cov_path = vim.fn.fnamemodify(string.sub(m, string.len(mod) + 2), ':p')
      local buffer_name = vim.api.nvim_buf_get_name(buf)
      if cov_path == buffer_name then
        local color = tonumber(t) == 1 and 'goCoverageCovered' or 'goCoverageNotCovered'
        bl = tonumber(bl) - 1
        el = tonumber(el) - 1
        bc = tonumber(bc) - 1
        ec = tonumber(ec) - 1
        for i = bl, el do
          if i == bl and i == el then
            vim.api.nvim_buf_add_highlight(buf, ns, color, i, bc, ec)
          elseif i == bl then
            vim.api.nvim_buf_add_highlight(buf, ns, color, i, bc, -1)
          elseif i == el then
            vim.api.nvim_buf_add_highlight(buf, ns, color, i, 0, ec)
          else
            vim.api.nvim_buf_add_highlight(buf, ns, color, i, 0, -1)
          end
        end
      end
    end
  end
end

function M.highlight_off()
  local ns = vim.api.nvim_get_namespaces()['go-coverage']
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

return M
