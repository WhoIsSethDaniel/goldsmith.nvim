local config = require("goldsmith.config").get('tags')

local M = {}

local function run(action, location, ...)
	if vim.o.modified then
		vim.api.nvim_err_writeln("Current buffer is modified. You must save before running this command.")
		return
	end
	local range
	if location.count > -1 then
		range = string.format("-line %d,%d", location.line1, location.line2)
	else
		range = string.format("-offset %d", vim.fn.line2byte(location.line1))
	end
	local tags = {}
	local options = {}
	local i = 1
	for _, ko in ipairs(...) do
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
	local cmd = string.format("gomodifytags -file %s -w %s -transform %s", cfile, range, config.transform)
	if config.skip_unexported then
		cmd = string.format("%s -skip-unexported", cmd)
	end
	if #tags > 0 then
		if #options > 0 then
			cmd = string.format("%s -%s-options %s", cmd, action, table.concat(options, ","))
			if action == "add" then
				cmd = string.format("%s -%s-tags %s", cmd, action, table.concat(tags, ","))
			end
		else
			cmd = string.format("%s -%s-tags %s", cmd, action, table.concat(tags, ","))
		end
	elseif action == "remove" then
		cmd = string.format("%s --clear-tags", cmd)
	elseif action == "add" then
		cmd = string.format("%s --add-tags %s", cmd, config.default_tag)
	end
	local ret = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		print(ret)
		vim.api.nvim_err_writeln("Failed to execute the following command:\n" .. vim.inspect(cmd))
	else
		vim.api.nvim_command("edit!")
	end
end

function M.add(line1, line2, count, ...)
	run("add", { line1 = line1, line2 = line2, count = count }, ...)
end

function M.remove(line1, line2, count, ...)
	run("remove", { line1 = line1, line2 = line2, count = count }, ...)
end

return M
