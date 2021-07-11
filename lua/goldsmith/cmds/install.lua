local async = require'goldsmith.async'
local config = require'goldsmith.config'

local M = {}

function M.run(...)
	async.run("go install", {}, ...)
end

return M

