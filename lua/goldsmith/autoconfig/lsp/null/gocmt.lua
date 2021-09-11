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
  return 'gocmt'
end

local function cmd()
  return tools.info(M.service_name())['cmd']
end

function M.has_requirements()
  return tools.is_installed 'gocmt'
end

function M.setup(user_args)
  return {
    name = M.service_name(),
    method = null.methods.FORMATTING,
    filetypes = { 'go' },
    generator = help.formatter_factory {
      command = cmd(),
      args = vim.list_extend(user_args, { '$FILENAME' })
    },
  }
end

return M
