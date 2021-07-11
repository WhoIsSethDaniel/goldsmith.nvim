local async = require'goldsmith.async'
local config = require'goldsmith.config'

local M = {}

function M.run(...)
	local cmd_cfg = config.get("goget") or {}
	local terminal_cfg = config.get("terminal")
	async.run("go get", vim.tbl_deep_extend("force", terminal_cfg, cmd_cfg), ...)
end

return M
