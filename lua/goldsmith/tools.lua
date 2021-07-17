local plugins = require 'goldsmith.plugins'

local M = {}

local TOOLS = {
  go = {
    status = 'expected',
    required = true,
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
    name = 'gopls',
    lspconfig_name = 'gopls',
    lspinstall_name = 'go',
    not_found = {
      'If you are using lspinstall this is expected',
      "If not, you can install with ':GoInstallBinaries gopls'",
    },
    get_version = function(cmd)
      local out = vim.fn.system(cmd .. ' version')
      return string.match(out, '@v([%d%.]+)')
    end,
  },
  ['efm-langserver'] = {
    status = 'install',
    location = 'github.com/mattn/efm-langserver',
    tag = 'latest',
    server = true,
    required = false,
    name = 'efm-langserver',
    lspconfig_name = 'efm',
    lspinstall_name = 'efm',
    not_found = {
      'If you are using lspinstall this is expected',
      "If not, you can install with ':GoInstallBinaries efm-langserver'",
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
    required = true,
    not_found = {
      'Struct tag manipulation will not work. i.e. :GoAddTags / :GoRemoveTags, etc...',
      "You can install with ':GoInstallBinaries gomodifytags'",
    },
  },
  gotests = {
    status = 'install',
    location = 'github.com/cweill/gotests/gotests',
    tag = 'latest',
    required = false,
    not_found = { 'This tool is not currently used' },
  },
  golines = {
    status = 'install',
    location = 'github.com/segmentio/golines',
    required = false,
    tag = 'latest',
    not_found = { 'This tool is not currently used' },
    get_version = function(cmd)
      local out = vim.fn.system(cmd .. ' --version')
      return string.match(out, 'v([%d%.]+)')
    end,
  },
  staticcheck = {
    status = 'install',
    location = 'honnef.co/go/tools/cmd/staticcheck',
    tag = 'latest',
    required = false,
    not_found = { 'This tool is not currently used' },
    get_version = function(cmd)
      local out = vim.fn.system(cmd .. ' -version')
      return string.match(out, '%(v([%d%.]+)%)')
    end,
  },
  revive = {
    status = 'install',
    location = 'github.com/mgechev/revive',
    tag = 'latest',
    required = false,
    not_found = { 'This tool is not currently used' },
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
      local cmd = string.format('%s/%s', li_util.install_path(info.lspinstall_name), info.name)
      if vim.fn.filereadable(cmd) ~= 0 then
        return cmd
      end
    else
      TOOLS[program].installed = true
      TOOLS[program].via = 'user installation'
      return vim.fn.exepath(program)
    end
  else
    return vim.fn.exepath(program)
  end
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
  return TOOLS[name].installed
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
  print(vim.inspect(TOOLS))
end

return M
