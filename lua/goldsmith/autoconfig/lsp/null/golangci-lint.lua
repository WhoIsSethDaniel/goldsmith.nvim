local tools = require 'goldsmith.tools'
local config = require 'goldsmith.config'
local log = require 'goldsmith.log'

local null = require 'null-ls'
local help = require 'null-ls.helpers'

local M = {}

local err_map = {
  {
    pat = "Can't read config.*no such file or directory",
    msg = "'golangci-lint' is not able to read its configuration file. You can use :GoCreateConfigs to create a working one.",
  },
  {
    pat = "Can't read config.*While parsing config",
    msg = "'golangci-lint' is not able to parse its configuration file: %s",
  },
}
local max_errs = 10

local function parse_messages()
  local severities = { error = 1, warning = 2, information = 3, hint = 4 }
  local config_warning = false
  local unknown_errs = 0
  return function(params, done)
    local errmsg = string.match(params.err or '', '^level=.*%s+msg=(.*)$')
    if errmsg ~= nil then
      done()
      for _, err in ipairs(err_map) do
        if string.match(errmsg, err.pat) ~= nil then
          if config_warning then
            return
          end
          config_warning = true
          log.error('Lint', string.format(err.msg, errmsg))
          return
        end
      end
      if unknown_errs == 0 then
        log.error('Lint', string.format("'golangci-lint' unknown error: %s", errmsg))
      end
      unknown_errs = unknown_errs + 1
      if unknown_errs > max_errs then
        unknown_errs = 0
      end
      return
    end
    config_warning = false
    unknown_errs = 0
    local ok, msgs = pcall(vim.fn.json_decode, params.err)
    if not ok or type(msgs) ~= 'table' then
      done()
      return
    end
    local diags = {}
    for _, d in ipairs(msgs.Issues) do
      table.insert(diags, {
        message = d.Text,
        col = d.Pos.Column,
        row = d.Pos.Line,
        source = d.FromLinter,
        severity = severities[d.Severity] or severities['warning'],
        filename = d.Pos.Filename,
      })
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
  local static_args = { 'run', '--out-format=json', '--fix=false', '--fast' }
  return {
    name = M.service_name(),
    method = null.methods.DIAGNOSTICS_ON_SAVE,
    filetypes = { 'go' },
    generator = help.generator_factory {
      diagnostics_format = '#{s}: #{m}',
      command = cmd(),
      to_stdin = false,
      args = function()
        local args = vim.deepcopy(static_args)
        local cf = M['config_file'] and M.config_file()
        if cf ~= nil then
          vim.list_extend(args, string.format('--config=%s', cf), vim.fn.fnamemodify(vim.fn.expand '%', ':p:h'))
        else
          vim.list_extend(args, { vim.fn.fnamemodify(vim.fn.expand '%', ':p:h') })
        end
        return vim.list_extend(args, user_args)
      end,
      multiple_files = true,
      format = 'raw',
      on_output = parse_messages(),
    },
  }
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
