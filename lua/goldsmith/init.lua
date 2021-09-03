local ac = require 'goldsmith.autoconfig'
local config = require 'goldsmith.config'

local M = {}

M.config = config.setup
M.setup = ac.register_server
M.init = ac.init
M.needed = ac.needed

M.client_configure = function(client)
  require('goldsmith.format').configure(client)
end

return M
