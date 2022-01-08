local config = require 'goldsmith.config'

local M = {}

function M.run()
  local oldiskeyword = vim.opt.iskeyword:get()
  vim.opt.iskeyword:append '.'
  vim.opt.iskeyword:append '/'

  local word = vim.fn.expand '<cword>'
  require('goldsmith.cmds.doc').run('doc', { word })

  vim.opt.iskeyword = oldiskeyword
end

return M
