local hints = require 'goldsmith.inlay_hints'

return {
  turn_off_inlay_hints = hints.disable_inlay_hints,
  turn_on_inlay_hints = hints.set_inlay_hints,
}
