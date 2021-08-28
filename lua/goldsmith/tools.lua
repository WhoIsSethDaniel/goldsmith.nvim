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
    minimum_version = '0.6.0',
    filetypes = { 'go', 'gomod' },
    module_name = 'gopls',
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
    null = true,
    not_found = { 'This is used to restrict line length to a particular number of columns.' },
    get_version = function(cmd)
      local out = vim.fn.system(cmd .. ' --version')
      return string.match(out, 'v([%d%.]+)')
    end,
  },
  gofmt = {
    required = false,
    location = "in your Go distribution.",
    tag = 'latest',
    exe = 'gofmt',
    null = true,
    not_found = { 'This is the standard code formatter for Go.' }
  },
  gofumpt = {
    status = 'install',
    location = 'mvdan.cc/gofumpt',
    required = false,
    tag = 'latest',
    exe = 'gofumpt',
    null = true,
    not_found = { 'This formats Go code the standard way, but a little more strictly.'  },
    get_version = function(cmd)
      local out = vim.fn.system(cmd .. ' -version')
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
    null = true,
    required = false,
    not_found = { 'This is a linting tool. It can supplement the linting done by gopls.' },
  },
  ['golangci-lint'] = {
    status = 'install',
    location = 'github.com/golangci/golangci-lint/cmd/golangci-lint',
    tag = 'latest',
    exe = 'golangci-lint',
    null = true,
    required = false,
    not_found = { 'This is a linting tool. It can supplement the linting done by gopls.' },
    get_version = function(cmd)
      local out = vim.fn.system(cmd .. ' --version')
      return string.match(out, 'v([%d%.]+)')
    end,
  },
  staticcheck = {
    status = 'install',
    location = 'honnef.co/go/tools/cmd/staticcheck',
    tag = 'latest',
    exe = 'staticcheck',
    null = true,
    required = false,
    not_found = { 'This is a linting tool. It can supplement the linting done by gopls.' },
    get_version = function(cmd)
      local out = vim.fn.system(cmd .. ' -version')
      return string.match(out, '%(v([%d%.]+)%)')
    end,
  },
  lspconfig = {
    name = 'nvim-lspconfig',
    required = true,
    installed = false,
    plugin = true,
    location = 'https://github.com/neovim/nvim-lspconfig',
    not_found = {
      'This plugin is used to configure the various LSP servers such as gopls.',
    },
    check_installed = function()
      local ok, _ = pcall(require, 'lspconfig')
      return ok
    end,
  },
  lspinstaller = {
    name = 'nvim-lsp-installer',
    required = false,
    installed = false,
    plugin = true,
    location = 'https://github.com/williamboman/nvim-lsp-installer',
    not_found = {
      'This plugin may be used to install the LSP servers such as gopls.',
    },
    check_installed = function()
      local ok, _ = pcall(require, 'nvim-lsp-installer')
      return ok
    end,
  },
  lspinstall = {
    name = 'nvim-lspinstall',
    required = false,
    installed = false,
    plugin = true,
    location = 'https://github.com/kabouzeid/nvim-lspinstall',
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
    filetypes = { 'go' },
    module_name = 'null',
    location = 'https://github.com/jose-elias-alvarez/null-ls.nvim',
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
    location = 'https://github.com/vim-test/vim-test',
    testing = true,
    weight = 1,
    not_found = {
      'This plugin can be used for running tests.',
      'It is highly recommended that you install this plugin.'
    },
    check_installed = function()
      return vim.fn.exists ':TestFile' == 2 and vim.fn.exists '*test#default_runners'
    end,
  },
  -- ultest = {
  --   name = 'vim-ultest',
  --   required = false,
  --   installed = false,
  --   plugin = true,
  --   location = 'https://github.com/rcarriga/vim-ultest',
  --   testing = true,
  --   weight = 10,
  --   not_found = {
  --     'This plugin is not currently used by Goldsmith.',
  --   },
  --   check_installed = function()
  --     local ok, _ = pcall(require, 'ultest')
  --     return ok
  --   end,
  -- },
  treesitter = {
    name = 'nvim-treesitter',
    required = true,
    installed = false,
    plugin = true,
    location = 'https://github.com/nvim-treesitter/nvim-treesitter',
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
    location = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
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
  FixCursorHold = {
    name = 'FixCursorHold',
    required = true,
    installed = false,
    plugin = true,
    location = 'https://github.com/antoinemadec/FixCursorHold.nvim',
    not_found = {
      'Much of Goldsmith will fail to work without this plugin.',
      'It is required to fix a bug with the CursorHold event in Neovim.',
    },
    check_installed = function()
      return vim.fn.exists 'g:loaded_fix_cursorhold_nvim' > 0
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
      local cmd = string.format('%s/%s', li_util.install_path(info.lspinstall_name), info.exe)
      if vim.fn.filereadable(cmd) ~= 0 then
        TOOLS[program].via = 'lspinstall'
        return cmd
      end
    end
    if plugins.is_installed('lspinstaller') then
      local _, s = require'nvim-lsp-installer'.get_server(program)
      local cmd = s._default_options.cmd[1]
      if cmd ~= nil and vim.fn.filereadable(cmd) ~= 0 then
        TOOLS[program].via = 'lsp-installer'
        return cmd
      end
    end
    TOOLS[program].via = 'user installation'
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
      if TOOLS[tool].cmd ~= nil then
        TOOLS[tool].installed = true
      end
      if TOOLS[tool].cmd == nil or TOOLS[tool].get_version == nil then
        TOOLS[tool].version = 'unknown'
      else
        TOOLS[tool].version = TOOLS[tool].get_version(TOOLS[tool].cmd)
      end
    end
  end
end

function M.info(name)
  return TOOLS[name]
end

function M.is_installed(name)
  if TOOLS[name].installed or TOOLS[name].cmd ~= nil then
    return true
  end
  return false
end

function M.is_required(name)
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
  require('goldsmith.log').debug('tools', function()
    return vim.inspect(TOOLS)
  end)
end

return M
