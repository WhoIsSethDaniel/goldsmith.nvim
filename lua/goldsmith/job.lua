local M = {}

function M.run(cmd, opts)
	local job = vim.fn.jobstart(cmd, opts)
	return job
end

return M
