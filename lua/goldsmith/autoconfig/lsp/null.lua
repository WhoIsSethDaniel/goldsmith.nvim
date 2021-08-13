local plugins = require 'goldsmith.plugins'
local config = require 'goldsmith.config'
local tools = require 'goldsmith.tools'

local null = require 'null-ls'
local help = require 'null-ls.helpers'

local M = {}

local parse_diag_messages = function()
  local severities = { error = 1, warning = 2, information = 3, hint = 4 }
  return function(msgs)
    local diags = {}
    for _, d in ipairs(msgs.output) do
      table.insert(diags, {
        message = d.Failure,
        col = d.Position.Start.Column,
        row = d.Position.Start.Line,
        source = d.Position.Start.Filename,
        severity = severities[d.Severity],
      })
    end
    return diags
  end
end

local function setup_revive(conf)
  return {
    name = 'revive',
    method = null.methods.DIAGNOSTICS,
    filetypes = { 'go' },
    generator = help.generator_factory {
      diagnostics_format = 'revive: #{m}',
      command = 'revive',
      to_stdin = false,
      args = { string.format('-config=%s', conf['config_file']), '-formatter=json', '$FILENAME' },
      format = 'json',
      on_output = parse_diag_messages(),
    },
  }
end

local function setup_golines(conf)
  return {
    name = 'golines',
    method = null.methods.FORMATTING,
    filetypes = { 'go' },
    generator = help.formatter_factory {
      command = 'golines',
      to_stdin = true,
      args = { string.format('--max-len=%d', conf['max_line_length']) },
    },
  }
end

function M.is_minimum_version()
  return true
end

function M.has_requirements()
  if plugins.is_installed 'null' then
    return true
  end
  return false
end

local function is_disabled(service)
  local disabled = config.get('null', 'disabled')
  if type(disabled) == 'boolean' and disabled == true then
    return true
  elseif type(disabled) == 'table' then
    if vim.tbl_isempty(disabled) then
      return true
    end
    if vim.tbl_contains(disabled, service) then
      return true
    end
  end
  return false
end

-- this needs to be cleaned up
function M.setup(cf)
  local choose = function(service)
    if service == 'golines' then
      return setup_golines(config.get 'format')
    else
      return setup_revive(config.get 'revive')
    end
  end
  local services = {}
  for _, service in ipairs { 'golines', 'revive' } do
    if tools.is_installed(service) and not is_disabled(service) then
      table.insert(services, choose(service))
    end
  end
  null.config(cf)
  null.register(services)
  require('lspconfig')['null-ls'].setup(cf)
end

return M
