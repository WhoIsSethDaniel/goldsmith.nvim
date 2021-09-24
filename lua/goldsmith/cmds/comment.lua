local config = require 'goldsmith.config'
local comment = require 'goldsmith.comment'

local M = {}

function M.run()
  comment.make_comments(config.get('format', 'comments', 'template'), config.get('format', 'comments', 'private'))
end

return M
