local ac = require 'goldsmith.autoconfig'
local config = require 'goldsmith.config'
local statusline = require 'goldsmith.statusline'
local fs = require 'goldsmith.fs'
local log = require 'goldsmith.log'
local go = require 'goldsmith.go'

_G.goldsmith_package_complete = function()
  local ok, l = go.list(false, { './...' })
  if not ok then
    log.error('Testing', 'Failed to find all packages for current module/project.')
  end
  local curpkgmatch = false
  local curpkg = vim.fn.fnamemodify(vim.fn.expand '%', ':h:.')
  local pkgs = {}
  for _, p in ipairs(l) do
    local d = vim.fn.fnamemodify(p.Dir, ':.')
    if curpkg ~= d then
      if d ~= vim.fn.getcwd() then
        table.insert(pkgs, fs.relative_to_cwd(d))
      end
    else
      curpkgmatch = true
    end
  end
  table.sort(pkgs)
  table.insert(pkgs, './...')
  table.insert(pkgs, '.')
  if curpkgmatch then
    table.insert(pkgs, fs.relative_to_cwd(curpkg))
  end
  return table.concat(pkgs, '\n')
end

local gid = vim.api.nvim_create_augroup('GoldsmithLspProgressEvent', { clear = true })
vim.api.nvim_create_autocmd('User', {
  group = gid,
  pattern = 'LspProgressUpdate',
  callback = function()
    require('goldsmith.ready').check_for_ready(vim.lsp.util.get_progress_messages())
  end,
})

return {
  config = config.setup,
  setup = ac.register_server,
  pre = ac.pre,
  init = ac.init,
  needed = ac.needed,
  status = statusline.status,
  client_configure = function(client)
    require('goldsmith.format').configure(client)
  end,
}
