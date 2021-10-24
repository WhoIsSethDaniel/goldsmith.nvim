local config = require 'goldsmith.config'
local log = require 'goldsmith.log'
local wb = require 'goldsmith.winbuf'
local diagnostic = require 'goldsmith.diagnostic'

local M = {}

local function jump(m)
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, m, params, function(_, a2, a3, a4)
    -- see https://github.com/neovim/neovim/pull/15504
    -- for the reason for the type check; essentially
    -- the signature for the lsp-handler changed
    local result = type(a4) == 'number' and a3 or a2
    if result == nil or vim.tbl_isempty(result) then
      log.info('Jump', 'No location found')
      return nil
    end

    local r
    if vim.tbl_islist(result) then
      r = result[1]
    else
      r = result
    end

    local b = vim.uri_to_bufnr(r.uri)
    if b ~= vim.fn.bufnr '%' and not config.get('jump', 'use_current_window') then
      local c = config.window_opts('jump', { reuse = b })
      wb.create_winbuf(c)
    end

    vim.lsp.util.jump_to_location(r)

    if #result > 1 then
      vim.lsp.util.set_qflist(vim.lsp.util.locations_to_items(result))
      vim.api.nvim_command 'copen'
    end
  end)
end

-- :GoDef
function M.goto_definition()
  jump 'textDocument/definition'
end

function M.goto_implementation()
  jump 'textDocument/implementation'
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
  jump 'textDocument/typeDefinition'
end

-- :GoRename <arg>
function M.rename(new)
  vim.lsp.buf.rename(new and new[1] or nil)
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
  diagnostic.open_float(0, { scope = 'line' })
end

-- :GoDiagList
function M.diag_set_loclist()
  -- takes optional args
  diagnostic.setloclist()
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

function M.add_workspace_folder()
  vim.lsp.buf.add_workspace_folder()
end

function M.remove_workspace_folder()
  vim.lsp.buf.remove_workspace_folder()
end

function M.list_workspace_folders()
  log.info(nil, vim.inspect(vim.lsp.buf.list_workspace_folders()))
end

function M.goto_previous_diagnostic()
  diagnostic.goto_prev()
end

function M.goto_next_diagnostic()
  diagnostic.goto_next()
end

return M
