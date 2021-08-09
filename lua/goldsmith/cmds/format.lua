local config = require 'goldsmith.config'

local M = {}

function M.run(uncond)
  M.run_lsp_format(uncond)
  M.run_goimports(uncond)
end

function M.run_lsp_format(uncond)
  if uncond == 1 or config.get('format', 'run_on_save') then
    vim.lsp.buf.formatting_seq_sync()
  end
end

function M.run_goimports(uncond)
  if uncond == 1 or config.get('goimports', 'run_on_save') then
    M.goimports(config.get('goimports', 'timeout'))
  end
end

-- taken from https://github.com/golang/tools/blob/master/gopls/doc/vim.md#neovim-imports
-- It is different in that this version supports multiple language servers (but only one will
-- be able to fulfill the request -- presumedly gopls).
-- This code is also similar to the codeAction handler defined at lua/vim/lsp/handlers.lua.
function M.goimports(timeout_ms)
  local context = { only = { 'source.organizeImports' } }
  -- local context = { source = { organizeImports = true } }
  vim.validate { context = { context, 't', true } }

  local params = vim.lsp.util.make_range_params()
  params.context = context

  -- See the implementation of the textDocument/codeAction callback
  -- (lua/vim/lsp/handler.lua) for how to do this properly.
  local results = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, timeout_ms)
  if not results or next(results) == nil then
    return
  end

  local actions = false
  for _, result in pairs(results) do
    if not vim.tbl_isempty(result) then
      actions = result.result
      if actions and not vim.tbl_isempty(actions) then
        break
      else
        actions = false
      end
    end
  end
  if not actions then
    return
  end
  local action = actions[1]

  -- textDocument/codeAction can return either Command[] or CodeAction[]. If it
  -- is a CodeAction, it can have either an edit, a command or both. Edits
  -- should be executed first.
  if action.edit or type(action.command) == 'table' then
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit)
    end
    if type(action.command) == 'table' then
      vim.lsp.buf.execute_command(action.command)
    end
  else
    vim.lsp.buf.execute_command(action)
  end
end

return M
