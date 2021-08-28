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
    if string.match(params.err or '', "Can't read config") ~= nil then
      done()
      if config_warning then
        return
      end
      config_warning = true
      log.error(
        'Lint',
        "'golangci-lint' must have a configuration file and one does not currently exist. You can use :GoCreateConfigs to create one."
      )
      return
    end
    config_warning = false
    local ok, msgs = pcall(vim.fn.json_decode, params.err)
    if not ok or type(msgs) ~= 'table' then
      done()
      return
    end
    local fname = vim.fn.fnamemodify(params.bufname, ':p:.')
    local diags = {}
    for _, d in ipairs(msgs.Issues) do
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
    done(diags)
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

function M.setup(user_args)
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
        local args
        local cf = conf['config_file']
        if cf ~= nil then
          args = {
            'run',
            '--out-format=json',
            string.format('--config=%s', cf),
            vim.fn.fnamemodify(vim.fn.expand '%', ':p:h'),
          }
        else
          args = { 'run', '--out-format=json', vim.fn.fnamemodify(vim.fn.expand '%', ':p:h') }
        end
        return vim.list_extend(args, user_args)
      end,
      format = 'raw',
      on_output = parse_messages(),
    },
  }
end

function M.get_config()
  return config.get 'golangci-lint' or {}
end

function M.config_file_contents()
  return [[
# for information on each linter see:
# https://golangci-lint.run/usage/linters/
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
    - gocritic
    - goconst
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
    - structcheck
    - stylecheck
    - thelper
    - tparallel
    - typecheck
    - unconvert
    - unparam
    - unused
    - varcheck
    - whitespace

run:
  issues-exit-code: 1
]]
end

return M
