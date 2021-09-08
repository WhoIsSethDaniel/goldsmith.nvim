local config = require 'goldsmith.config'
local format = require 'goldsmith.format'
local mod = require 'goldsmith.mod'

local M = {}

function M.run(uncond)
  local ft = vim.opt.filetype:get()
  if ft == 'go' then
    M.run_lsp_format(uncond)
    M.run_organize_imports(uncond)
  elseif ft == 'gomod' then
    M.run_mod_format(uncond)
  end
end

function M.run_mod_format(uncond)
  if uncond == 1 or config.get('format', 'run_on_save') then
    mod.format()
  end
end

function M.run_lsp_format(uncond)
  if uncond == 1 or config.get('format', 'run_on_save') then
    vim.lsp.buf.formatting_seq_sync()
  end
end

function M.run_organize_imports(uncond)
  if uncond == 1 or config.get('goimports', 'run_on_save') then
    format.organize_imports(config.get('goimports', 'timeout'))
  end
end

return M
