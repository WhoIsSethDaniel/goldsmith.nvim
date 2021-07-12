local config = require("goldsmith.config")

local M = {}

local function run(action, ...)
	local offset = vim.fn.line2byte(vim.fn.line("."))
	local tags = {}
	local options = {}
	local i = 1
	for _, ko in ipairs({ ... }) do
		for w in string.gmatch(ko, "%w+") do
			if tags[i] ~= nil then
				table.insert(options, string.format("%s=%s", tags[i], w))
				break
			else
				table.insert(tags, w)
			end
		end
		i = i + 1
	end
	local cfile = vim.fn.shellescape(vim.fn.expand("%"))
	local cmd = string.format("gomodifytags -file %s -w -offset %s", cfile, offset, action, table.concat(tags, ","))
	if #tags > 0 then
		cmd = string.format("%s -%s-tags %s", cmd, action, table.concat(tags, ","))
		if #options > 0 then
			cmd = string.format("%s -%s-options %s", cmd, action, table.concat(options, ","))
		end
	elseif action == "remove" then
		cmd = string.format("%s --clear-tags", cmd)
	elseif action == "add" then
		cmd = string.format("%s --add-tags json", cmd)
	end
	local out = vim.fn.system(cmd)
	vim.api.nvim_command("edit!")
end

function M.add(...)
	run("add", ...)
end

function M.remove(...)
	run("remove", ...)
end

return M
