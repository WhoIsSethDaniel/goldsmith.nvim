local mod = require'goldsmith.mod'

local M = {}

M.check_for_upgrades = mod.check_for_upgrades
M.tidy = mod.tidy
M.retract = mod.retract
M.exclude = mod.exclude
M.replace = mod.replace

return M
