local tools = require 'goldsmith.tools'
local config = require 'goldsmith.config'
local log = require 'goldsmith.log'

local null = require 'null-ls'
local help = require 'null-ls.helpers'

local M = {}

local function get_config()
  return config.get 'format' or {}
end

function M.service_name()
  return 'golines'
end

local function cmd()
  return tools.info(M.service_name())['cmd']
end

function M.has_requirements()
  return tools.is_installed 'golines'
end

function M.check_and_warn_about_requirements()
  if not tools.is_installed 'golines' then
    log.error('Format', "'golines' is not installed and will not be run by null-ls. Use ':GoInstallBinaries golines' to install it")
    return false
  end
  return true
end

function M.setup()
  local conf = get_config()
  return {
    name = M.service_name(),
    method = null.methods.FORMATTING,
    filetypes = { 'go' },
    generator = help.formatter_factory {
      command = cmd(),
      to_stdin = true,
      args = { string.format('--max-len=%d', conf['max_line_length']) },
    },
  }
end

return M
