local config = require("goldsmith.config")
local job = require("goldsmith.job")

local M = {}

function M.complete(arglead, cmdline, cursorPos)
	local names = config.tool_names()
	return table.concat(names, "\n")
end

function M.run(...)
	local install = {}
	if ... ~= nil then
		local possibles = config.tool_names()
		for _, k in ipairs(possibles) do
			for _, n in ipairs({ ... }) do
				if k == n then
					table.insert(install, k)
					break
				end
			end
		end
	else
		install = config.tool_names()
	end
	if #install == 0 then
		vim.api.nvim_err_writeln("Nothing to install!")
		return
	end
	local tinfo = config.tool_info()
	for _, name in ipairs(install) do
		local info = tinfo[name]
		local cmd = string.format("go install %s@%s", info.location, info.tag)
		job.run(name, cmd, {})
	end
end

return M
