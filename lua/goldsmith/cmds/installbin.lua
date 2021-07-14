local tools = require("goldsmith.tools")
local job = require("goldsmith.job")

local M = {}

function M.complete(arglead, cmdline, cursorPos)
	local names = tools.names({ status = "install" })
	return table.concat(names, "\n")
end

function M.run(...)
	local install = {}
	if ... ~= nil then
		local possibles = tools.names({ status = "install" })
		for _, k in ipairs(possibles) do
			for _, n in ipairs({ ... }) do
				if k == n then
					table.insert(install, k)
					break
				end
			end
		end
	else
		install = tools.names({ status = "install" })
	end
	if #install == 0 then
		vim.api.nvim_err_writeln("Nothing to install!")
		return
	end
	for _, name in ipairs(install) do
		local info = tools.info(name)
		local cmd = string.format("go install %s@%s", info.location, info.tag)
		job.run(name, cmd, {})
	end
end

return M
