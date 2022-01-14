local tools = require 'goldsmith.tools'
local config = require 'goldsmith.config'
local log = require 'goldsmith.log'

local null = require 'null-ls'
local help = require 'null-ls.helpers'

local M = {}

local function parse_messages()
  local severities = { error = 1, warning = 2, information = 3, hint = 4 }
  return function(msg, params)
    local ok, d = pcall(vim.fn.json_decode, msg)
    return {
      message = d.message,
      col = d.location.column,
      row = d.location.line,
      severity = severities[d.severity],
      code = d.code,
      source = 'staticcheck',
      filename = d.location.file,
    }
  end
end

function M.service_name()
  return 'staticcheck'
end

local function cmd()
  return tools.info(M.service_name())['cmd']
end

function M.has_requirements()
  return tools.is_installed 'staticcheck'
end

function M.setup(user_args)
  return {
    name = M.service_name(),
    method = null.methods.DIAGNOSTICS_ON_SAVE,
    filetypes = { 'go' },
    generator = help.generator_factory {
      diagnostics_format = 'staticcheck: #{m}',
      command = cmd(),
      to_stdin = false,
      to_stderr = true,
      check_exit_code = function(code)
        return code <= 1
      end,
      args = vim.list_extend({ '-f=json', vim.fn.fnamemodify(vim.fn.expand '%', ':p:h') }, user_args),
      format = 'line',
      multiple_files = true,
      on_output = parse_messages(),
      use_cache = false,
      timeout = 5000,
    },
  }
end

function M.get_config()
  return config.get 'staticcheck' or {}
end

return M
