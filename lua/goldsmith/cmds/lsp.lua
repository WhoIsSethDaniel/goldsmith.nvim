local M = {}

-- :GoDef ctrl-] gd
function M.goto_definition()
  vim.lsp.buf.definition()
end

function M.goto_implementation()
   vim.lsp.buf.implementation()
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
  vim.lsp.buf.type_definition()
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

return M
