local tools = require 'goldsmith.tools'
local config = require 'goldsmith.config'
local log = require 'goldsmith.log'

local null = require 'null-ls'
local help = require 'null-ls.helpers'

local M = {}

local function parse_messages()
  local severities = { error = 1, warning = 2, information = 3, hint = 4 }
  return function(msgs)
    local diags = {}
    for _, d in ipairs(msgs.output) do
      table.insert(diags, {
        message = d.Failure,
        col = d.Position.Start.Column,
        row = d.Position.Start.Line,
        severity = severities[d.Severity],
      })
    end
    return diags
  end
end

function M.service_name()
  return 'revive'
end

local function cmd()
  return tools.info(M.service_name())['cmd']
end

function M.has_requirements()
  local conf = M.get_config()
  return tools.is_installed 'revive' and vim.fn.filereadable(conf['config_file']) == 0
end

function M.check_and_warn_about_requirements()
  if not tools.is_installed 'revive' then
    log.error(nil, 'Format', "'revive' is not installed and will not be run by null-ls. Use ':GoInstallBinaries revive' to install it")
    return false
  end
  local conf = M.get_config()
  if vim.fn.filereadable(conf['config_file']) == 0 then
    log.error(nil, 'Format', "'revive' must have a configuration file and one does not currently exist. You can use :GoCreateConfigs to create one.")
    return false
  end
  return true
end

function M.setup()
  local conf = M.get_config()
  return {
    name = M.service_name(),
    method = null.methods.DIAGNOSTICS,
    filetypes = { 'go' },
    generator = help.generator_factory {
      diagnostics_format = 'revive: #{m}',
      command = cmd(),
      to_stdin = false,
      args = { string.format('-config=%s', conf['config_file']), '-formatter=json', '$FILENAME' },
      format = 'json',
      on_output = parse_messages(),
    },
  }
end

function M.get_config()
  return config.get('revive')
end

function M.config_file_contents()
  return [[
# for more information about revive and its
# configuration please see here:
# https://github.com/mgechev/revive#configuration
ignoreGeneratedHeader = false
severity = "warning"
confidence = 0.8
errorCode = 0
warningCode = 0

[rule.blank-imports]
[rule.context-as-argument]
[rule.context-keys-type]
[rule.dot-imports]
[rule.error-return]
[rule.error-strings]
[rule.error-naming]
[rule.exported]
[rule.if-return]
[rule.increment-decrement]
[rule.var-naming]
[rule.var-declaration]
[rule.package-comments]
[rule.range]
[rule.receiver-naming]
[rule.time-naming]
[rule.unexported-return]
[rule.indent-error-flow]
[rule.errorf]
[rule.empty-block]
[rule.superfluous-else]
[rule.unused-parameter]
[rule.unreachable-code]
[rule.redefines-builtin-id]
]]
end

return M
