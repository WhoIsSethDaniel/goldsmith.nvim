local M = {}

-- for now, these keys are a-ok
local ACCEPTED_KEYS = { "pos", "focus", "cols", "rows" }

function M.run(cmd, async_args, ...)
	local args = ""
	for _, a in ipairs({ ... }) do
		args = args .. " " .. a
	end

	-- turn the given table into a string that looks like
	-- a vim dictionary
	local dict = ""
	for _, k in ipairs(ACCEPTED_KEYS) do
		local v = async_args[k]
		if v ~= nil and type(v) ~= "table" then
			if type(v) == "boolean" and v == true then
				v = "v:true"
			elseif type(v) == "boolean" and v == false then
				v = "v:false"
			end
			dict = string.format('%s "%s": "%s",', dict, k, v)
		end
	end

	local asyncrun = [[ call asyncrun#run( "", { "mode": "terminal", %s }, "%s %s") ]]
	print(string.format(asyncrun, dict, cmd, args))
	vim.api.nvim_command(string.format(asyncrun, dict, cmd, args))
end

return M
