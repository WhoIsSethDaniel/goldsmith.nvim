local config = require 'goldsmith.config'
local plugins = require 'goldsmith.plugins'

local M = {}

function M.run(...)
  local cmd_cfg = config.get 'golint' or {}
  if plugins.is_installed('lint') then
    require('lint').try_lint()
  end
end

return M
