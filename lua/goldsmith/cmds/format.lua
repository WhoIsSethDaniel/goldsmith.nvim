local fmt = require 'goldsmith.format'
local config = require 'goldsmith.config'

local M = {}

function M.format_go_file()
  fmt.lsp_format()
  if config.get('format', 'goimports') then
    fmt.organize_imports()
  end
  if config.get('format', 'comments') then
    fmt.make_comments()
  end
end

function M.format_gomod_file()
  fmt.mod_format()
end

function M.run(uncond)
  local ros = config.get('format', 'run_on_save')
  if not uncond and not ros then
    return false
  end
  local ft = vim.opt.filetype:get()
  if uncond or (not uncond and ros) then
    if ft == 'go' then
      M.format_go_file()
    elseif ft == 'gomod' then
      M.format_gomod_file()
    end
  end
  return true
end

return M
