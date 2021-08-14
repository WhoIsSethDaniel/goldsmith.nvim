local config = require 'goldsmith.config'
local log = require 'goldsmith.log'

local M = {}

local function golangci_lint_config()
  return [[
linters-settings:
  errcheck:
    check-type-assertions: true
  goconst:
    min-len: 2
    min-occurrences: 3
  gocritic:
    enabled-tags:
      - diagnostic
      - experimental
      - opinionated
      - performance
      - style
  govet:
    check-shadowing: true
  nolintlint:
    require-explanation: true
    require-specific: true

linters:
  disable-all: true
  enable:
    - bodyclose
    - deadcode
    - depguard
    - dogsled
    - dupl
    - errcheck
    - exportloopref
    - exhaustive
    - goconst
    - gofmt
    - goimports
    - gocyclo
    - gosec
    - gosimple
    - govet
    - ineffassign
    - misspell
    - nolintlint
    - nakedret
    - prealloc
    - predeclared
    - staticcheck
    - structcheck
    - stylecheck
    - thelper
    - tparallel
    - typecheck
    - unconvert
    - unparam
    - varcheck
    - whitespace
    - gocritic

run:
  issues-exit-code: 1
]]
end

local function revive_config()
  return [[
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

local configs = { golangci_lint = { k = 'golangci-lint', c = golangci_lint_config }, revive = { k = 'revive', c = revive_config } }

function M.create_configs(overwrite)
  for name, v in pairs(configs) do
    local filename = config.get(v.k, 'config_file')

    if overwrite ~= '!' and vim.fn.filereadable(filename) > 0 then
      goto continue
    end
    local f, err = io.open(filename, 'w')
    if f == nil then
      log.error(nil, 'Lint', string.format("Cannot create file '%s': %s", filename, err))
      goto continue
    end

    f:write(v.c())
    print(string.format("Created configuration file '%s'", filename))
    ::continue::
  end
end

return M
