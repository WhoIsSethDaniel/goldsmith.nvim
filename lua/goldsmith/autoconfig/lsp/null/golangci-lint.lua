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

local function get_config()
  return config.get 'golangci-lint'
end

local function name()
  return 'golangci-lint'
end

local function cmd()
  return tools.info(name())['cmd']
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
  local conf = get_config()
  return {
    name = name(),
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

return M
