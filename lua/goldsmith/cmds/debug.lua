local log = require 'goldsmith.log'

local M = {}

function M.run()
  log.toggle_debug_console()
end

return M
