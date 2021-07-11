local async = require'goldsmith.async'

local M = {}

function M.run(...)
	async.run("go build", {}, ...)
end

return M
