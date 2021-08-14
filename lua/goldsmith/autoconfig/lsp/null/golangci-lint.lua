local tools = require 'goldsmith.tools'
local config = require 'goldsmith.config'
local log = require 'goldsmith.log'

local null = require 'null-ls'
local help = require 'null-ls.helpers'

local M = {}

local parse_messages = function()
  local severities = { error = 1, warning = 2, information = 3, hint = 4 }
  return function(msgs)
    local diags = {}
    local fname = vim.fn.fnamemodify(msgs.bufname, ':p:.')
    for _, d in ipairs(msgs.output.Issues) do
      if fname == d.Pos.Filename then
        table.insert(diags, {
          message = d.Text,
          col = d.Pos.Column,
          row = d.Pos.Line,
          source = d.FromLinter,
          severity = severities[d.Severity] or severities['warning'],
        })
      end
    end
    return diags
  end
end

function M.service_name()
  return 'golangci-lint'
end

local function cmd()
  return tools.info(M.service_name())['cmd']
end

function M.has_requirements()
  return tools.is_installed 'golangci-lint'
end

function M.check_and_warn_about_requirements()
  if not tools.is_installed 'golangci-lint' then
    log.error(
      nil,
      'Format',
      "'golangci-lint' is not installed and will not be run by null-ls. Use ':GoInstallBinaries golangci-lint' to install it"
    )
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
      diagnostics_format = '#{s}: #{m}',
      command = cmd(),
      to_stdin = false,
      args = function()
        local cf = conf['config_file']
        if vim.fn.filereadable(cf) > 0 then
          return {
            'run',
            '--out-format=json',
            string.format('--config=%s', cf),
            vim.fn.fnamemodify(vim.fn.expand '%', ':p:h'),
          }
        else
          return { 'run', '--out-format=json', vim.fn.fnamemodify(vim.fn.expand '%', ':p:h') }
        end
      end,
      to_stderr = true,
      format = 'json',
      on_output = parse_messages(),
    },
  }
end

function M.get_config()
  return config.get 'golangci-lint'
end

function M.config_file_contents()
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

return M
