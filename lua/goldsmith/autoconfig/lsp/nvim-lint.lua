local plugins = require 'goldsmith.plugins'
local config = require 'goldsmith.config'

local M = {}

local DEFAULTS = {
  linters_by_ft = {
    go = { 'revive' },
  },
}

function M.has_config()
  if plugins.is_installed 'lint' then
    return true
  end
  return false
end

function M.config()
  local cf = config.get('revive')
  local lint = require 'lint'
  if lint.linters_by_ft['go'] == nil then
    lint.linters_by_ft = vim.tbl_deep_extend('force', DEFAULTS.linters_by_ft, lint.linters_by_ft)
  else
    table.insert(lint.linters_by_ft.go, 'revive')
  end
  lint.linters.revive.args = { '-config', cf['config_file'] }
  vim.cmd [[
    augroup Goldsmith_Auto_Lint
      au!
      au BufWinEnter,TextChanged,TextChangedI *.go lua require('lint').try_lint()
    augroup END
  ]]
end

return M
