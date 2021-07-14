local M = {}

function M.run(name, cmd, opts)
	print(string.format("starting retrieval of %s", name))
	local job = vim.fn.jobstart(cmd, {
		on_exit = function(jobid, code, event)
			if code > 0 then
				vim.api.nvim_err_writeln(string.format("FAILED in retrieval of %s, code %d", name, code))
			else
				print(string.format("SUCCESS in retrieval of %s", name, code))
			end
		end,
	})
end

return M
