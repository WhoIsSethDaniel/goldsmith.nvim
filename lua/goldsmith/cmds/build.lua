local async = require'goldsmith.async'
local config = require'goldsmith.confg'

local M = {}

function M.run(...)
	local cmd_cfg = config.get("gobuild") or {}
	local terminal_cfg = config.get("terminal")
	async.run("go build", vim.tbl_deep_extend("force", terminal_cfg, cmd_cfg), ...)
end

return M
