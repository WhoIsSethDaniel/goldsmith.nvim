local M = {}

local TOOLS = {
  go = {
    required = true,
    exe = 'go',
    not_found = { 'This is required' },
    get_version = function(cmd)
      local out = vim.fn.system(cmd .. ' version')
      return string.match(out, ' go([%d%.]+)')
    end,
  },
  gopls = {
    status = 'install',
    location = 'golang.org/x/tools/gopls',
    tag = 'latest',
    server = true,
    required = true,
    exe = 'gopls',
    lspconfig_name = 'gopls',
    lspinstall_name = 'go',
    not_found = { 'This is required to do many things. It should be installed.' },
    get_version = function(cmd)
      local out = vim.fn.system(cmd .. ' version')
      return string.match(out, '@v([%d%.]+)')
    end,
  },
  gomodifytags = {
    status = 'install',
    location = 'github.com/fatih/gomodifytags',
    tag = 'latest',
    required = false,
    exe = 'gomodifytags',
    not_found = {
      'This is used to manipulate struct tags',
      'It is required if you want to use the :GoAddTags, :GoRemoveTags, ... commands.',
    },
  },
  gotests = {
    status = 'install',
    location = 'github.com/cweill/gotests/gotests',
    tag = 'latest',
    required = false,
    exe = 'gotests',
    not_found = {
      'This is used to generate stub tests in your test file.',
      'It is required if you want to use the :GoAddTests or :GoAddTest commands.',
    },
  },
  golines = {
    status = 'install',
    location = 'github.com/segmentio/golines',
    required = false,
    tag = 'latest',
    exe = 'golines',
    not_found = { 'This is used to restrict line length to a particular number of columns.' },
    get_version = function(cmd)
      local out = vim.fn.system(cmd .. ' --version')
      return string.match(out, 'v([%d%.]+)')
    end,
  },
  impl = {
    status = 'install',
    location = 'github.com/josharian/impl',
    tag = 'latest',
    required = false,
    exe = 'impl',
    not_found = {
      'This is used to generate a stub implementation of an interface.',
      'It is required if you want to use the :GoImpl command.',
    },
  },
  fixplurals = {
    status = 'install',
    location = 'github.com/davidrjenni/reftools/cmd/fixplurals',
    tag = 'latest',
    exe = 'fixplurals',
    required = false,
    not_found = {
      'This is used to remove redundant parameter and result types from function signatures.',
      'It is required if you want to use the :GoFixPlurals command.',
    },
  },
  revive = {
    status = 'install',
    location = 'github.com/mgechev/revive',
    tag = 'latest',
    exe = 'revive',
    required = false,
    not_found = { 'This is a linting tool. It can supplement the linting done by gopls.' },
  },
  lspconfig = {
    name = 'nvim-lspconfig',
    required = true,
    installed = false,
    plugin = true,
    not_found = {
      'This plugin is used to configure the various LSP servers such as gopls.',
    },
    check_installed = function()
      local ok, _ = pcall(require, 'lspconfig')
      return ok
    end,
  },
  lspinstall = {
    name = 'nvim-lspinstall',
    required = false,
    installed = false,
    plugin = true,
    not_found = {
      'This plugin may be used to install the LSP servers such as gopls.',
    },
    check_installed = function()
      local ok, _ = pcall(require, 'lspinstall')
      return ok
    end,
  },
  null = {
    name = 'null-ls',
    required = false,
    installed = false,
    plugin = true,
    server = true,
    lspconfig_name = 'null-ls',
    lspinstall_name = 'null-ls',
    not_found = {
      "This plugin is used for running supplemental linters and formatters such as 'revive' and 'golines'.",
    },
    check_installed = function()
      local ok, _ = pcall(require, 'null-ls')
      return ok
    end,
  },
  test = {
    name = 'vim-test',
    required = false,
    installed = false,
    plugin = true,
    not_found = {
      'This plugin is not currently used by Goldsmith.',
    },
    check_installed = function()
      return vim.fn.exists ':TestFile' == 2 and vim.fn.exists '*test#default_runners'
    end,
  },
  ultest = {
    name = 'vim-ultest',
    required = false,
    installed = false,
    plugin = true,
    not_found = {
      'This plugin is not currently used by Goldsmith.',
    },
    check_installed = function()
      local ok, _ = pcall(require, 'ultest')
      return ok
    end,
  },
  treesitter = {
    name = 'nvim-treesitter',
    required = true,
    installed = false,
    plugin = true,
    not_found = {
      'This plugin is used by Goldsmith in many places. Much of Goldsmith will fail to work without it.',
    },
    check_installed = function()
      local ok, _ = pcall(require, 'nvim-treesitter')
      return ok
    end,
  },
  ['treesitter-textobjects'] = {
    name = 'nvim-treesitter-textobjects',
    required = false,
    installed = false,
    plugin = true,
    not_found = {
      'This plugin is used to configure a number of neovim textobjects and navigation shortcuts.',
      'See |goldsmith-text-objects| for more information.',
    },
    check_installed = function()
      if vim.fn.exists ':TSInstall' == 2 then
        local modules = require('nvim-treesitter.configs').available_modules()
        for _, m in ipairs(modules) do
          if m == 'textobjects.select' then
            return true
          end
        end
        return false
      end
    end,
  },
}

function M.find_bin(program, info)
  local plugins = require 'goldsmith.plugins'

  if info.server and info['exe'] ~= nil then
    TOOLS[program].installed = false
    local li_installed = false
    local li_util
    if plugins.is_installed 'lspinstall' then
      local li = require 'lspinstall'
      li_util = require 'lspinstall.util'
      li_installed = li.is_server_installed(info.lspinstall_name)
    end
    if li_installed then
      TOOLS[program].installed = true
      TOOLS[program].via = 'lspinstall'
      local cmd = string.format('%s/%s', li_util.install_path(info.lspinstall_name), info.exe)
      if vim.fn.filereadable(cmd) ~= 0 then
        return cmd
      end
    else
      TOOLS[program].installed = true
      TOOLS[program].via = 'user installation'
    end
  end
  local cmd = vim.fn.exepath(TOOLS[program].exe)
  if cmd == '' then
    return
  end
  return cmd
end

-- check that tool exists and executable, also get its version
-- if possible
function M.check(names)
  local tools = names or M.names()
  for _, tool in ipairs(tools) do
    if TOOLS[tool]['plugin'] == true then
      TOOLS[tool].installed = TOOLS[tool].check_installed()
      TOOLS[tool].version = 'unknown'
    else
      TOOLS[tool].cmd = M.find_bin(tool, TOOLS[tool])
      if TOOLS[tool].cmd == nil or TOOLS[tool].get_version == nil then
        TOOLS[tool].version = 'unknown'
      else
        TOOLS[tool].version = TOOLS[tool].get_version(TOOLS[tool].cmd)
      end
    end
  end
end

function M.info(name)
  M.check { name }
  return TOOLS[name]
end

function M.is_installed(name)
  M.check { name }
  return TOOLS[name].installed
end

function M.is_required(name)
  M.check { name }
  return TOOLS[name].required
end

function M.names(attrs)
  local names = {}
  for k, v in pairs(TOOLS) do
    if attrs == nil then
      table.insert(names, k)
    else
      for ak, av in pairs(attrs) do
        if v[ak] == av then
          table.insert(names, k)
        end
      end
    end
  end
  return names
end

function M.dump()
  print(vim.inspect(TOOLS))
end

return M
