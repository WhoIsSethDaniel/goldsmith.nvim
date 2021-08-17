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
    if d.location.file == params.bufname then
      return {
        message = d.message,
        col = d.location.column,
        row = d.location.line,
        severity = severities[d.severity],
      }
    end
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

function M.check_and_warn_about_requirements()
  if not tools.is_installed 'staticcheck' then
    log.error(
      'Format',
      "'staticcheck' is not installed and will not be run by null-ls. Use ':GoInstallBinaries staticcheck' to install it"
    )
    return false
  end
  local conf = M.get_config()
  if vim.fn.filereadable(conf['config_file']) == 0 then
    log.error(
      'Format',
      "'staticcheck' must have a configuration file and one does not currently exist. You can use :GoCreateConfigs to create one."
    )
    return false
  end
  return true
end

function M.setup()
  return {
    name = M.service_name(),
    method = null.methods.DIAGNOSTICS,
    filetypes = { 'go' },
    generator = help.generator_factory {
      diagnostics_format = 'staticcheck: #{m}',
      command = cmd(),
      to_stdin = false,
      to_stderr = true,
      args = { '-f=json', vim.fn.fnamemodify(vim.fn.expand '%', ':p:h') },
      format = 'line',
      on_output = parse_messages(),
      use_cache = false,
      timeout = 5000,
    },
  }
end

function M.get_config()
  return config.get 'staticcheck' or {}
end

function M.config_file_contents()
  return [[
]]
end

return M