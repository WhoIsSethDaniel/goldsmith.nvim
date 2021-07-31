local cmds = require 'goldsmith.lsp.cmds'
local ts = require 'goldsmith.treesitter'
local job = require 'goldsmith.job'

local M = {}

function M.check_for_upgrades()
  local modules = ts.get_all_modules()
  cmds.check_for_upgrades(modules)
end

function M.tidy()
  vim.cmd[[ silent! wall ]]
  cmds.tidy()
end

function M.format()
  vim.cmd[[ silent! wall ]]
  job.run('go mod edit -fmt', {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stderr = function(chan, data, name)
      vim.api.nvim_err_writeln(data[1])
    end,
    on_exit = function(jobid, code, event)
      if code > 0 then
        return
      end
      print('Requested formatting is done.')
      vim.cmd[[ silent! e! ]]
    end
  })

end

return M
