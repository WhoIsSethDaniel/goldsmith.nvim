local servers = require'goldsmith.lsp.servers'
local ac = require'goldsmith.autoconfig'
local conf = require'goldsmith.config'

local M = {}
local registered_servers = {}

-- global goldsmith config
function M.config(cf)
  conf.setup(cf)
end

local function get_server_conf(server)
  local cf = conf.get(server)['config']
  if cf == nil then
    return {}
  end
  if type(cf) == 'function' then
    return cf()
  elseif type(cf) == 'table' then
    return cf
  else
    vim.api.nvim_err_writeln(string.format("Configuration type for key '%s' must be table or function", server))
    return {}
  end
end

function M.init()
  for _, s in ipairs(registered_servers) do
    ac.setup_server(s, get_server_conf(s))
  end
  ac.config_servers()
end

-- setup a goldsmith managed lsp server
function M.setup(server)
  local ok, sn = servers.is_server(server)
  if ok then
    if not vim.tbl_contains(registered_servers, sn) then
      table.insert(registered_servers, sn)
    end
    return true
  end
  return false
end

return M
