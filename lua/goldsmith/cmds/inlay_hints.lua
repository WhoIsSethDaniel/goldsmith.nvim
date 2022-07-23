local hints = require 'goldsmith.inlay_hints'

return {
  turn_off_inlay_hints = function()
    vim.b.inlay_hints = nil
    hints.disable_inlay_hints()
  end,
  turn_on_inlay_hints = function()
    vim.b.inlay_hints = true
    hints.set_inlay_hints()
  end,
}
