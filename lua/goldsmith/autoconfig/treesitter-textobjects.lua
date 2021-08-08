local to = require 'nvim-treesitter.configs'
local plugins = require 'goldsmith.plugins'

local M = {}

function M.has_requirements()
  if plugins.is_installed 'treesitter' and plugins.is_installed 'treesitter-textobjects' then
    return true
  end
  return false
end

function M.setup()
  to.setup {
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ['af'] = { go = '@function.outer' },
          ['if'] = { go = '@function.inner' },
          ['ac'] = { go = '@comment.outer' },
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          [']]'] = { go = '@function.outer' },
        },
        goto_previous_start = {
          ['[['] = { go = '@function.outer' },
        },
      },
    },
  }
end

return M
