local plugins = require 'goldsmith.plugins'

local M = {}

local TOOLS = {
  go = {
    status = 'expected',
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
  efm = {
    status = 'install',
    location = 'github.com/mattn/efm-langserver',
    tag = 'latest',
    server = true,
    required = false,
    exe = 'efm-langserver',
    lspconfig_name = 'efm',
    lspinstall_name = 'efm',
    not_found = {
      'This is required if you want to do extra linting or formatting. It can supplement gopls.',
    },
    get_version = function(cmd)
      local out = vim.fn.system(cmd .. ' -v')
      return string.match(out, 'efm%-langserver ([%d%.]+)')
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
}

function M.find_bin(program, info)
  if info.server then
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
    TOOLS[tool].cmd = M.find_bin(tool, TOOLS[tool])
    if TOOLS[tool].cmd == nil or TOOLS[tool].get_version == nil then
      TOOLS[tool].version = 'unknown'
    else
      TOOLS[tool].version = TOOLS[tool].get_version(TOOLS[tool].cmd)
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
