local diagnostic = require 'goldsmith.diagnostic'

local M = {}

-- { {
--     result = { {
--         command = {
--           arguments = { {
--               Fix = "fill_struct",
--               Range = {
--                 end = {
--                   character = 18,
--                   line = 23
--                 },
--                 start = {
--                   character = 6,
--                   line = 23
--                 }
--               },
--               URI = "file:///home/seth/src/snago/json.go"
--             } },
--           command = "gopls.apply_fix",
--           title = "Fill GoVersions"
--         },
--         edit = {},
--         kind = "refactor.rewrite",
--         title = "Fill GoVersions"
--       } }
--   } }
function M.run(timeout_ms)
  local context = { diagnostics = diagnostic.get() }
  local params = vim.lsp.util.make_range_params()
  params.context = context
  local results = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, timeout_ms)
  if not results or next(results) == nil then
    return
  end

  if results == nil then
    return
  end
  for _, result in ipairs(results) do
    if result['result'] ~= nil then
      for _, action in ipairs(result.result) do
        local is_fill = false
        for _, arg in ipairs(action.command.arguments) do
          if arg['Fix'] == 'fill_struct' then
            is_fill = true
            break
          end
        end
        if type(action.command) == 'table' and is_fill then
          vim.lsp.buf.execute_command(action.command)
          return
        end
      end
    end
  end
end

return M
