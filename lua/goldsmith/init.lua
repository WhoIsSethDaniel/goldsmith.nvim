local ac = require 'goldsmith.autoconfig'
local config = require 'goldsmith.config'
local map = require 'goldsmith.mappings'

local M = {}

M.config = config.setup
M.setup = ac.register_server
M.init = ac.init
M.set_buffer_mappings = map.set_buffer_mappings

return M
