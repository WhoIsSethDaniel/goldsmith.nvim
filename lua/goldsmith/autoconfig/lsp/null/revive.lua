local tools = require 'goldsmith.tools'
local config = require 'goldsmith.config'
local log = require 'goldsmith.log'

local null = require 'null-ls'
local help = require 'null-ls.helpers'

local M = {}

local err_map = {
  {
    pat = 'cannot read',
    msg = "'revive' is not able to read its configuration file. You can use :GoCreateConfigs to create a working one.",
  },
  { pat = 'cannot parse', msg = "'revive' is not able to parse its configuration file: %s" },
}
local max_errs = 10

local function parse_messages()
  local severities = { error = 1, warning = 2, information = 3, hint = 4 }
  local config_warning = false
  local unknown_errs = 0
  return function(params, done)
    if params['err'] ~= nil then
      done()
      for _, err in ipairs(err_map) do
        if string.match(params.err, err.pat) ~= nil then
          if config_warning then
            return
          end
          config_warning = true
          log.error('Lint', string.format(err.msg, params.err))
          return
        end
      end
      unknown_errs = unknown_errs + 1
      if unknown_errs == max_errs then
        log.error('Lint', string.format("'revive' unknown error: %s", params.err))
      end
      return
    end
    config_warning = false
    unknown_errs = 0
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
        source = 'revive',
        filename = d.Position.Start.Filename
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
  return {
    name = M.service_name(),
    method = null.methods.DIAGNOSTICS_ON_SAVE,
    filetypes = { 'go' },
    generator = help.generator_factory {
      diagnostics_format = 'revive: #{m}',
      command = cmd(),
      to_stdin = false,
      check_exit_code = function(code)
        return code == 0
      end,
      args = function()
        local args
        local cf = M['config_file'] and M.config_file()
        if cf == nil then
          args = { '-formatter=json', '$FILENAME' }
        else
          args = { string.format('-config=%s', cf), '-formatter=json', '$FILENAME' }
        end
        return vim.list_extend(args, user_args)
      end,
      format = 'raw',
      multiple_files = true,
      on_output = parse_messages(),
    },
  }
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
