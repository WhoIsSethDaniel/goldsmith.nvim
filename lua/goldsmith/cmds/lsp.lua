local config = require 'goldsmith.config'
local log = require 'goldsmith.log'
local wb = require 'goldsmith.winbuf'

local M = {}

local function jump(m)
  local params = vim.lsp.util.make_position_params()
   vim.lsp.buf_request(0, m, params, function(_, method, result)
    if result == nil or vim.tbl_isempty(result) then
      log.info('Jump', 'No location found')
      return nil
    end

    local c = vim.tbl_deep_extend('force', config.get('window'), config.get('jump') or {})
    if not c['use_current_window'] then
      wb.create_winbuf(c)
    end

    if vim.tbl_islist(result) then
      vim.lsp.util.jump_to_location(result[1])

      if #result > 1 then
        vim.lsp.util.set_qflist(vim.lsp.util.locations_to_items(result))
        vim.api.nvim_command 'copen'
      end
    else
      vim.lsp.util.jump_to_location(result)
    end
  end)
end

-- :GoDef
function M.goto_definition()
  jump('textDocument/definition')
end

function M.goto_implementation()
  jump('textDocument/implementation')
end

-- :GoInfo
function M.hover()
  vim.lsp.buf.hover()
end

-- :GoSigHelp
function M.signature_help()
  vim.lsp.buf.signature_help()
end

-- :GoDefType :GoTypeDef
function M.type_definition()
  jump('textDocument/typeDefinition')
end

-- :GoRename <arg>
function M.rename(new)
  vim.lsp.buf.rename(new)
end

-- :GoCodeAction
function M.code_action()
  vim.lsp.buf.code_action()
end

-- :GoRef
function M.references()
  -- takes optional <context> arg
  vim.lsp.buf.references()
end

-- :GoDiagShow
function M.show_diagnostics()
  -- takes many optional args
  vim.lsp.diagnostic.show_line_diagnostics()
end

-- :GoDiagList
function M.diag_set_loclist()
  -- takes optional args
  vim.lsp.diagnostic.set_loclist()
end

-- :GoSymHighlight
function M.highlight_current_symbol()
  vim.lsp.buf.clear_references()
  vim.lsp.buf.document_highlight()
end

-- :GoSymHighlightOff
function M.turn_off_symbol_highlighting()
  config.set('highlight', 'current_symbol', false)
  vim.lsp.buf.clear_references()
end

-- :GoSymHighlightOn
function M.turn_on_symbol_highlighting()
  config.set('highlight', 'current_symbol', true)
  vim.lsp.buf.clear_references()
  vim.lsp.buf.document_highlight()
end

-- :GoCodeLensOff
function M.turn_off_codelens()
  config.set('codelens', 'show', false)
  local all_ns = vim.api.nvim_get_namespaces()
  for client_id, _ in pairs(vim.lsp.get_active_clients()) do
    local ns = string.format('vim_lsp_codelens:%d', client_id)
    local nsid = all_ns[ns]
    if nsid ~= nil then
      local buffers = vim.lsp.get_buffers_by_client_id(client_id)
      for _, buffer_id in ipairs(buffers) do
        vim.api.nvim_buf_clear_namespace(buffer_id, nsid, 0, -1)
      end
    end
  end
end

-- :GoCodeLensOn
function M.turn_on_codelens()
  config.set('codelens', 'show', true)
  vim.lsp.codelens.refresh()
end

-- :GoCodeLensRun
function M.run_codelens()
  vim.lsp.codelens.run()
end

function M.format()
  require('goldsmith.cmds.format').run(1)
end

function M.add_workspace_folder()
  vim.lsp.buf.add_workspace_folder()
end

function M.remove_workspace_folder()
  vim.lsp.buf.remove_workspace_folder()
end

function M.list_workspace_folders()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end

function M.goto_previous_diagnostic()
  vim.lsp.diagnostic.goto_prev()
end

function M.goto_next_diagnostic()
  vim.lsp.diagnostic.goto_next()
end

return M
