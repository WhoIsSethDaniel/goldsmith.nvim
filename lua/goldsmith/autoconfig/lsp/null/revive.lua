local tools = require 'goldsmith.tools'
local config = require 'goldsmith.config'
local log = require 'goldsmith.log'

local null = require 'null-ls'
local help = require 'null-ls.helpers'

local M = {}

local function parse_messages()
  local severities = { error = 1, warning = 2, information = 3, hint = 4 }
  local config_warning = false
  return function(params, done)
    if string.match(params.err or '', 'cannot read') ~= nil then
      done()
      if config_warning then
        return
      end
      config_warning = true
      log.error(
        'Lint',
        "'revive' must have a configuration file and one does not currently exist. You can use :GoCreateConfigs to create one."
      )
      return
    end
    config_warning = false
    local ok, msgs = pcall(vim.fn.json_decode, params.output)
    if not ok or type(msgs) ~= 'table' then
      done()
      return
    end
    local diags = {}
    for _, d in ipairs(msgs) do
      table.insert(diags, {
        message = d.Failure,
        col = d.Position.Start.Column,
        row = d.Position.Start.Line,
        severity = severities[d.Severity],
      })
    end
    done(diags)
  end
end

function M.service_name()
  return 'revive'
end

local function cmd()
  return tools.info(M.service_name())['cmd']
end

function M.has_requirements()
  return tools.is_installed 'revive'
end

function M.setup(user_args)
  local conf = M.get_config()
  return {
    name = M.service_name(),
    method = null.methods.DIAGNOSTICS,
    filetypes = { 'go' },
    generator = help.generator_factory {
      diagnostics_format = 'revive: #{m}',
      command = cmd(),
      to_stdin = false,
      args = function()
        local args
        if conf['config_file'] == nil then
          args = { '-formatter=json', '$FILENAME' }
        else
          args = { string.format('-config=%s', conf['config_file']), '-formatter=json', '$FILENAME' }
        end
        return vim.list_extend(args, user_args)
      end,
      format = 'raw',
      on_output = parse_messages(),
    },
  }
end

function M.get_config()
  return config.get 'revive' or {}
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
