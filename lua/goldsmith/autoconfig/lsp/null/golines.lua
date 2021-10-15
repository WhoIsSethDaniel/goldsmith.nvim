local tools = require 'goldsmith.tools'
local config = require 'goldsmith.config'

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

function M.setup(user_args)
  local conf = get_config()
  return {
    name = M.service_name(),
    method = null.methods.FORMATTING,
    filetypes = { 'go' },
    generator = help.formatter_factory {
      command = cmd(),
      to_stdin = true,
      args = vim.list_extend(
        { string.format('--max-len=%d', conf['max_line_length']), '--base-formatter=gofmt' },
        user_args
      ),
    },
  }
end

return M
