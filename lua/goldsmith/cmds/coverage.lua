local config = require 'goldsmith.config'
local log = require 'goldsmith.log'
local job = require 'goldsmith.job'
local coverage = require 'goldsmith.coverage'
local fs = require 'goldsmith.fs'

local M = {}

local current_job
local profile_files = {}

function M.stop()
  if current_job ~= nil then
    os.remove(profile_files[current_job])
    if vim.fn.jobwait({ current_job }, 0)[1] == -1 then
      log.warn('Testing', 'Killing currently running profile job')
      vim.fn.jobstop(current_job)
    end
  end
  for _, f in pairs(profile_files) do
    os.remove(f)
  end
  coverage.highlight_off()
end

function M.run(bang, args)
  if current_job ~= nil then
    if vim.fn.jobwait({ current_job }, 0)[1] == -1 then
      if bang == '!' then
        log.warn('Testing', 'Killing currently running profile job')
        vim.fn.jobstop(current_job)
      else
        log.warn('Testing', 'There is a currently running profile job. Add "!" to kill current job.')
        return
      end
    end
  end
  local b = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(b)
  local profile_file = os.tmpname()
  local cmd = vim.list_extend(
    { 'go', 'test', string.format('-coverprofile=%s', profile_file), vim.fn.fnamemodify(buf_name, ':p:h') },
    args
  )
  local opts = {}
  current_job = job.run(cmd, opts, {
    on_stderr = function(id, data)
      if data[1] ~= '' then
        log.error('Coverage', data[1])
      end
    end,
    on_exit = function(id, code)
      local pf = profile_files[id]
      -- if id is not current_job then this job has been canceled
      if id ~= current_job then
        os.remove(pf)
        return
      end
      log.info('Testing', string.format('Running profile finished with code %d', code))
      if code ~= 0 then
        os.remove(pf)
        return
      end
      if fs.is_test_file(buf_name) then
        local cf = fs.code_file_name(vim.fn.expand(buf_name))
        if vim.fn.filereadable(cf) > 0 then
          vim.api.nvim_buf_call(b, function()
            vim.cmd(string.format('silent! e! %s', cf))
          end)
        else
          log.warn('Coverage', string.format('Cannot show coverage for non-existent file "%s".', cf))
          os.remove(pf)
          return
        end
      end
      coverage.highlight_on(b, pf)
      os.remove(pf)
    end,
  })
  profile_files[current_job] = profile_file
end

return M
