local coverage = require 'goldsmith.coverage'
local job = require 'goldsmith.job'
local buffer = require 'goldsmith.buffer'

local M = {}

local prefix = '🇬 '
local coverage_indicators = { '⨁', '╌' }
local max_length = 40

local count_sym = {
  '①',
  '②',
  '③',
  '④',
  '⑤',
  '⑥',
  '⑦',
  '⑧',
  '⑨',
  '⑩',
  '⑪',
  '⑫ ',
  '⑬ ',
  '⑭ ',
  '⑮',
}
local too_many_jobs = '∞'

function M.status()
  if not buffer.is_goldsmith_buffer() then
    return
  end
  local line = { prefix }
  if coverage.has_coverage(vim.api.nvim_buf_get_name(0)) then
    table.insert(line, coverage_indicators[1])
  else
    table.insert(line, coverage_indicators[2])
  end
  local running_jobs = job.running_jobs()
  if not vim.tbl_isempty(running_jobs) then
    table.insert(line, count_sym[vim.tbl_count(running_jobs)] or too_many_jobs)
    local j = {}
    if j ~= nil then
      local len = 0
      for _, cmd in pairs(running_jobs) do
        local i
        if len > max_length then
          break
        end
        if type(cmd) == 'table' then
          i = string.format('[%s %s ...]', cmd[1], cmd[2])
        elseif type(cmd) == 'string' then
          local m = string.match(cmd, '^([^%s]+%s+[^%s]+)')
          if m ~= nil then
            i = string.format('[%s ...]', m)
          end
        end
        if i ~= nil then
          table.insert(j, i)
          len = len + #i
        end
      end
      table.insert(line, table.concat(j, ','))
    end
  end
  return table.concat(line, '')
end

return M
