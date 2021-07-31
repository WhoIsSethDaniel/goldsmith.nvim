local M = {}

local PLUGINS = {
  lspconfig = {
    name = 'nvim-lspconfig',
    required = true,
    installed = false,
    check_installed = function()
      return vim.g.lspconfig == 1
    end,
  },
  lspinstall = {
    name = 'nvim-lspinstall',
    required = false,
    installed = false,
    check_installed = function()
      return vim.fn.exists '*lspinstall#installed_servers' == 1
    end,
  },
  lint = {
    name = 'nvim-lint',
    required = false,
    installed = false,
    check_installed = function()
      local ok, _ = pcall(require, 'lint')
      return ok
    end,
  },
  test = {
    name = 'vim-test',
    required = false,
    installed = false,
    check_installed = function()
      return vim.fn.exists ':TestFile' == 2 and vim.fn.exists '*test#default_runners'
    end,
  },
  ultest = {
    name = 'vim-ultest',
    required = false,
    installed = false,
    check_installed = function()
      local ok, _ = pcall(require, 'ultest')
      return ok
    end,
  },
  treesitter = {
    name = 'nvim-treesitter',
    required = false,
    installed = false,
    check_installed = function()
      return vim.fn.exists ':TSInstall' == 2
    end,
  },
  ['treesitter-textobjects'] = {
    name = 'nvim-treesitter-textobjects',
    required = false,
    installed = false,
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

function M.names()
  local names = {}
  for s, _ in pairs(PLUGINS) do
    table.insert(names, s)
  end
  return names
end

function M.check()
  for p, pm in pairs(PLUGINS) do
    PLUGINS[p].installed = pm.check_installed()
  end
  return M
end

function M.info(plugin)
  M.check(plugin)
  return PLUGINS[plugin]
end

function M.is_required(plugin)
  M.check(plugin)
  return PLUGINS[plugin].required
end

function M.is_installed(plugin)
  M.check(plugin)
  return PLUGINS[plugin].installed
end

function M.dump()
  print(vim.inspect(PLUGINS))
end

return M
