local config = require 'goldsmith.config'
local comment = require 'goldsmith.comment'

local M = {}

function M.run()
  comment.make_comments(config.get('format', 'comments_template'), config.get('format', 'comments_all'))
end

return M
