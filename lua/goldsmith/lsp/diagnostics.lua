local M = {
  setting = {},
  underline = { default = true, options = { severity_limit = 4 } },
  virtual_text = { default = true, options = { severity_limit = 4 } },
  signs = { default = true, options = { severity_limit = 4 } },
  update_in_insert = { default = true, options = { severity_limit = 4 } },
  severity_sort = true
}

function M.toggle_underline()
  if M.setting.underline == nil then
    M.setting.underline = M.underline.default
  end
  if M.setting.underline == true then
    M.setting.underline = false
    return false
  elseif M.setting.underline == false then
    M.setting.underline = true
    return M.underline.options
  end
end

function M.toggle_virtual_text()
  if M.setting.virtual_text == nil then
    M.setting.virtual_text = M.virtual_text.default
  end
  if M.setting.virtual_text == true then
    M.setting.virtual_text = false
    return false
  elseif M.setting.virtual_text == false then
    M.setting.virtual_text = true
    return M.virtual_text.options
  end
end

function M.toggle_signs()
  if M.setting.signs == nil then
    M.setting.signs = M.signs.default
  end
  if M.setting.signs == true then
    M.setting.signs = false
    return false
  elseif M.setting.signs == false then
    M.setting.signs = true
    return M.signs.options
  end
end

function M.toggle_update_in_insert()
  if M.setting.update_in_insert == nil then
    M.setting.update_in_insert = M.update_in_insert.default
  end
  if M.setting.update_in_insert == true then
    M.setting.update_in_insert = false
    return false
  elseif M.setting.update_in_insert == false then
    M.setting.update_in_insert = true
    return M.update_in_insert.options
  end
end

function M.toggle_diagnostics()
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = M.toggle_underline(),
    virtual_text = M.toggle_virtual_text(),
    signs = M.toggle_signs(),
    update_in_insert = M.toggle_update_in_insert()
  })
  print(vim.inspect(M))
end

return M
