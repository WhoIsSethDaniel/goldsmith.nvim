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
  return 'gofumpt'
end

local function cmd()
  return tools.info(M.service_name())['cmd']
end

function M.has_requirements()
  return tools.is_installed 'gofumpt'
end

function M.setup(user_args)
  local f = null.builtins.formatting.gofumpt
  if user_args == nil then
    return { sources = { f } }
  end
  return { sources = { f.with { args = user_args } } }
end

return M
