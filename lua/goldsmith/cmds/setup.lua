local log = require 'goldsmith.log'
local ac = require 'goldsmith.autoconfig'

local M = {}

function M.complete()
  local names = {}
  ac.map(function(name, m)
    if m['get_config'] == nil then
      return
    end
    local f = m.get_config()['config_file']
    if f == nil then
      return
    end
    table.insert(names, f)
  end)
  table.sort(names)
  return table.concat(names, '\n')
end

function M.create_configs(overwrite, args)
  local files = {}
  for _, f in ipairs(args) do
    if not vim.tbl_contains(files, f) then
      table.insert(files, f)
    end
  end
  local created = 0
  ac.map(function(name, m)
    if m['get_config'] == nil or m['config_file_contents'] == nil then
      return
    end
    local c = m.get_config()
    local filename = c['config_file']
    if not vim.tbl_isempty(files) and not vim.tbl_contains(files, filename) then
      return
    end
    if filename == nil or (overwrite ~= '!' and vim.fn.filereadable(filename) > 0) then
      return
    end
    local f, err = io.open(filename, 'w')
    if f == nil then
      log.error('Setup', string.format("Cannot create file '%s': %s", filename, err))
      return
    end

    f:write(m.config_file_contents())
    created = created + 1
    print(string.format("Created configuration file '%s'", filename))
  end)
  if created == 0 then
    log.info('Setup', "No files created. Do they already exist? (try using '!' to overwrite). Check that you have a defined 'config_file' for each service.")
  end
end

return M
