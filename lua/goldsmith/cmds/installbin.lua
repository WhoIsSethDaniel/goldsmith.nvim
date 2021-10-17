local tools = require 'goldsmith.tools'
local job = require 'goldsmith.job'
local log = require 'goldsmith.log'

local M = {}

function M.complete(arglead, cmdline, cursorPos)
  local names = tools.names { status = 'install' }
  local exes = {}
  for _, name in ipairs(names) do
    local info = tools.info(name)
    table.insert(exes, info.exe)
  end
  table.sort(exes)
  return table.concat(exes, '\n')
end

function M.run(args)
  local install = {}
  if not vim.tbl_isempty(args) then
    local possibles = tools.names { status = 'install' }
    for _, k in ipairs(possibles) do
      for _, n in ipairs(args) do
        if k == n then
          table.insert(install, k)
          break
        end
      end
    end
  else
    install = tools.names { status = 'install' }
  end
  if #install == 0 then
    log.error('GoInstallBinaries', 'Nothing to install')
    return
  end
  for _, name in ipairs(install) do
    local info = tools.info(name)
    local cmd = { 'go', 'install', string.format("%s@%s", info.location, info.tag)}
    log.info('GoInstallBinaries', string.format('starting retrieval of %s', name))
    job.run(cmd, {
      on_exit = function(jobid, code, event)
        if code > 0 then
          log.error('GoInstallBinaries', string.format('FAILED in retrieval of %s, code %d', info.exe, code))
        else
          log.info('GoInstallBinaries', string.format('SUCCESS in retrieval of %s', info.exe, code))
        end
      end,
    })
  end
end

return M
