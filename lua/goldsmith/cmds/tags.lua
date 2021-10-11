local config = require('goldsmith.config').get 'tags'
local job = require 'goldsmith.job'
local tools = require 'goldsmith.tools'
local log = require 'goldsmith.log'

local M = {}

function M.run(action, location, args)
  local range
  if location.count > -1 then
    range = string.format('-line %d,%d', location.line1, location.line2)
  else
    range = string.format('-offset %d', vim.fn.line2byte(location.line1))
  end
  local tags = {}
  local options = {}
  local i = 1
  for _, ko in ipairs(args) do
    for w in string.gmatch(ko, '%w+') do
      if tags[i] ~= nil then
        table.insert(options, string.format('%s=%s', tags[i], w))
        break
      else
        table.insert(tags, w)
      end
    end
    i = i + 1
  end
  local cfile = vim.fn.shellescape(vim.fn.expand '%')
  local bin = tools.info('gomodifytags').cmd
  local cmd = string.format('%s -format json -file %s -w %s -transform %s', bin, cfile, range, config.transform)
  if config.skip_unexported then
    cmd = string.format('%s -skip-unexported', cmd)
  end
  if #tags > 0 then
    if #options > 0 then
      cmd = string.format('%s -%s-options %s', cmd, action, table.concat(options, ','))
      if action == 'add' then
        cmd = string.format('%s -%s-tags %s', cmd, action, table.concat(tags, ','))
      end
    else
      cmd = string.format('%s -%s-tags %s', cmd, action, table.concat(tags, ','))
    end
  elseif action == 'remove' then
    cmd = string.format('%s --clear-tags', cmd)
  elseif action == 'add' then
    cmd = string.format('%s --add-tags %s', cmd, config.default_tag)
  end
  local b = vim.api.nvim_get_current_buf()
  job.run(vim.split(cmd, ' '), {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stderr = function(jobid, data)
      if data[1] ~= '' then
        log.error('Tag', string.format('operation failed with: %s', data[1]))
      end
    end,
    on_stdout = function(jobid, data)
      if data[1] ~= '' then
        local changes = vim.fn.json_decode(data)
        vim.api.nvim_buf_set_lines(b, changes.start - 1, changes['end'], true, changes.lines)
        vim.cmd 'w!'
      end
    end,
    on_exit = function(jobid, code, event)
      if code > 0 then
        return
      end
    end,
  })
end

return M
