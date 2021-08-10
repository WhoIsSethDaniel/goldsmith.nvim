local plugins = require 'goldsmith.plugins'
local config = require 'goldsmith.config'

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

function M.setup(cf)
  local golines = setup_golines(config.get 'format')
  local revive = setup_revive(config.get 'revive')
  null.config(cf)
  null.register { revive, golines }
  require('lspconfig')['null-ls'].setup(cf)
end

return M
