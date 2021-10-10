local go = require 'goldsmith.go'
local log = require 'goldsmith.log'

local M = {}

local coverage_ns = 'go-coverage'
local coverage_data = {}
local coverage_files = {}

local function process_coverage_file(pf)
  coverage_data = {}
  coverage_files = {}
  local f = io.open(pf)
  local mod = M.module_path()
  for line in f:lines() do
    local m, bl, bc, el, ec, _, cnt = string.match(line, '^(.*):(%d+)%.(%d+),(%d+)%.(%d+)%s+(%d+)%s+(%d+)$')
    if m ~= nil then
      bl = tonumber(bl) - 1
      el = tonumber(el) - 1
      bc = tonumber(bc) - 1
      ec = tonumber(ec) - 1
      local cov_path = vim.fn.fnamemodify(string.sub(m, string.len(mod) + 2), ':p')
      table.insert(
        coverage_data,
        { file = cov_path, module = m, begin_line = bl, end_line = el, begin_column = bc, end_column = ec, cnt = cnt }
      )
      coverage_files[cov_path] = true
    end
  end
end

function M.has_coverage(f)
  return coverage_files[f]
end

function M.files()
  local rel_files = vim.tbl_keys(coverage_files)
  table.sort(rel_files)
  local files = {}
  for _, f in ipairs(rel_files) do
    table.insert(files, vim.fn.fnamemodify(f, ':p:.'))
  end
  return files
end

function M.show_coverage_files()
  if vim.tbl_isempty(coverage_files) then
    log.warn('Coverage', 'No coverage files currently available.')
    return
  end
  local files = vim.tbl_keys(coverage_files)
  table.sort(files)
  for _, f in ipairs(files) do
    print(vim.fn.fnamemodify(f, ':p:.'))
  end
end

function M.module_path()
  local mod = go.module_path()
  if mod == nil then
    log.warn('Coverage', 'Cannot determine import path for current project.')
    mod = ''
  end
  return mod
end

function M.add_coverage_file(pf)
  process_coverage_file(pf)
end

function M.highlight_on(buf)
  if not M.has_coverage(vim.api.nvim_buf_get_name(buf)) then
    log.warn('Coverage', 'Current buffer does not have coverage data.')
    return
  end
  local ns = vim.api.nvim_create_namespace(coverage_ns)
  local lc = vim.api.nvim_buf_line_count(buf)
  for i = 0, lc do
    vim.api.nvim_buf_add_highlight(buf, ns, 'goCoverageNormal', i, 0, -1)
  end
  for _, cd in pairs(coverage_data) do
    local bl, el, bc, ec, cnt = cd.begin_line, cd.end_line, cd.begin_column, cd.end_column, cd.cnt
    if cd.file == vim.api.nvim_buf_get_name(buf) then
      local color = tonumber(cnt) == 1 and 'goCoverageCovered' or 'goCoverageNotCovered'
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

function M.highlight_off()
  local ns = vim.api.nvim_get_namespaces()[coverage_ns]
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

return M
