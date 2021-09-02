local config = require 'goldsmith.config'
local format = require 'goldsmith.format'

local M = {}

function M.run(uncond)
  M.run_lsp_format(uncond)
  M.run_organize_imports(uncond)
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
