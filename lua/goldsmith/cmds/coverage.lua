local log = require 'goldsmith.log'
local job = require 'goldsmith.job'
local coverage = require 'goldsmith.coverage'
local fs = require 'goldsmith.fs'

local M = {}

local current_job
local profile_files = {}

function M.stop()
  if current_job ~= nil then
    if vim.fn.jobwait({ current_job }, 0)[1] == -1 then
      log.warn('Coverage', 'Killing currently running profile job')
      vim.fn.jobstop(current_job)
      current_job = nil
    end
  end
  for _, f in pairs(profile_files) do
    os.remove(f)
  end
end

function M.off()
  coverage.highlight_off()
end

function M.on()
  coverage.highlight_on(vim.api.nvim_get_current_buf())
end

function M.show_files()
  coverage.show_coverage_files()
end

function M.open_browser(pf)
  local cmd = { 'go', 'tool', 'cover', string.format('-html=%s', pf) }
  current_job = job.run(cmd, {
    on_stderr = function(id, data)
      if data[1] ~= '' then
        log.error('Coverage', data[1])
      end
    end,
    on_exit = function(id, code)
      log.info('Coverage', string.format('Launching browser finished with code %d', code))
    end,
  })
end

function M.run(attr, args)
  args = args or {}
  if current_job ~= nil then
    if vim.fn.jobwait({ current_job }, 0)[1] == -1 then
      if attr.bang == '!' then
        log.warn('Coverage', 'Killing currently running coverage job')
        vim.fn.jobstop(current_job)
      else
        log.warn('Coverage', 'There is a currently running coverage job. Add "!" to kill current job.')
        return
      end
    end
  end
  local b = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(b)
  local profile_file = os.tmpname()

  local has_file_arg = false
  for i, arg in ipairs(args) do
    if arg == '--' then
      table.remove(args, i)
      table.insert(args, i, fs.relative_to_cwd(vim.fn.expand '%'))
      has_file_arg = true
      break
    end
    if fs.is_valid_package(arg) then
      has_file_arg = true
      break
    end
  end
  if not has_file_arg then
    table.insert(args, fs.relative_to_cwd(vim.fn.expand '%'))
  end

  local cmd = vim.list_extend({ 'go', 'test', string.format('-coverprofile=%s', profile_file) }, args)
  local opts = {}
  current_job = job.run(cmd, opts, {
    on_stderr = function(id, data)
      if data[1] ~= '' then
        log.error('Coverage', data[1])
      end
    end,
    on_exit = function(id, code)
      local pf = profile_files[id]
      if id ~= current_job then
        return
      end
      log.info('Coverage', string.format('Running coverage finished with code %d', code))
      if code ~= 0 then
        return
      end
      if attr.type == 'job' then
        if fs.is_test_file(buf_name) then
          local cf = fs.code_file_name(vim.fn.expand(buf_name))
          if vim.fn.filereadable(cf) > 0 then
            vim.api.nvim_buf_call(b, function()
              vim.cmd(string.format('silent! e! %s', cf))
            end)
          end
        end
        coverage.add_coverage_file(pf)
        coverage.highlight_on(b)
      elseif attr.type == 'web' then
        M.open_browser(pf)
        coverage.add_coverage_file(pf)
      end
    end,
  })
  profile_files[current_job] = profile_file
end

return M
