local ac = require 'goldsmith.autoconfig'
local config = require 'goldsmith.config'
local statusline = require 'goldsmith.statusline'

return {
  config = config.setup,
  setup = ac.register_server,
  init = ac.init,
  needed = ac.needed,
  status = statusline.status,
  client_configure = function(client)
    require('goldsmith.format').configure(client)
  end,
}
