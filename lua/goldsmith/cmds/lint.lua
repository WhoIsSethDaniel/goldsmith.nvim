local config = require'goldsmith.config'
local log = require 'goldsmith.log'

local M = {}

local function write_revive_config(f)
  f:write[[
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

function M.create_configs()
  local filename = config.get('revive', 'config_file')

  if vim.fn.filereadable(filename) > 0 then
    log.error(nil, 'Lint', string.format("File '%s' already exists", filename))
    return
  end
  local f, err = io.open(filename, 'a')
  if f == nil then
    log.error(nil, 'Lint', string.format("Cannot create file '%s': %s", filename, err))
    return
  end

  write_revive_config(f)
  print(string.format("Created configuration file '%s'", filename))
end

return M
