local log = require 'goldsmith.log'
local ac = require 'goldsmith.autoconfig'

local M = {}

function M.complete()
  local names = {}
  ac.map(function(name, m)
    if m['config_file'] == nil then
      return
    end
    table.insert(names, name)
  end)
  table.sort(names)
  return table.concat(names, '\n')
end

function M.create_configs(overwrite, services)
  local svcs = {}
  for _, s in ipairs(services) do
    if not vim.tbl_contains(svcs, s) then
      table.insert(svcs, s)
    end
  end
  local created = 0
  ac.map(function(name, m)
    if m['config_file'] == nil then
      return
    end
    if not vim.tbl_isempty(svcs) and not vim.tbl_contains(svcs, name) then
      return
    end
    local filename = m.config_file()
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
    log.info('Setup', string.format("Created configuration file '%s'", filename))
  end)
  if created == 0 then
    log.info(
      'Setup',
      "No files created. Do they already exist? (try using '!' to overwrite). Check that you have a defined 'config_file' for each service."
    )
  end
end

return M
