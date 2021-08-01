local M = {}

local PLUGINS = {
  lspconfig = {
    name = 'nvim-lspconfig',
    required = true,
    installed = false,
    not_found = {
      "This plugin is used to configure the various LSP servers such as gopls."
    },
    check_installed = function()
      return vim.g.lspconfig == 1
    end,
  },
  lspinstall = {
    name = 'nvim-lspinstall',
    required = false,
    installed = false,
    not_found = {
      "This plugin may be used to install the LSP servers such as gopls."
    },
    check_installed = function()
      return vim.fn.exists '*lspinstall#installed_servers' == 1
    end,
  },
  lint = {
    name = 'nvim-lint',
    required = false,
    installed = false,
    not_found = {
      "This plugin is used for running supplemental linters such as 'revive'.",
    },
    check_installed = function()
      local ok, _ = pcall(require, 'lint')
      return ok
    end,
  },
  test = {
    name = 'vim-test',
    required = false,
    installed = false,
    not_found = {
      "This plugin is not currently used by Goldsmith."
    },
    check_installed = function()
      return vim.fn.exists ':TestFile' == 2 and vim.fn.exists '*test#default_runners'
    end,
  },
  ultest = {
    name = 'vim-ultest',
    required = false,
    installed = false,
    not_found = {
      "This plugin is not currently used by Goldsmith."
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
    not_found = {
      "This plugin is used by Goldsmith in many places. Much of Goldsmith will fail to work without it."
    },
    check_installed = function()
      return vim.fn.exists ':TSInstall' == 2
    end,
  },
  ['treesitter-textobjects'] = {
    name = 'nvim-treesitter-textobjects',
    required = false,
    installed = false,
    not_found = {
      "This plugin is used to configure a number of neovim textobjects and navigation shortcuts.",
      "See |goldsmith-text-objects| for more information."
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
