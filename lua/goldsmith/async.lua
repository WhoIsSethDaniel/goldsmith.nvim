local M = {}

function M.run(cmd, async_args, ...)
	local args = ""
	for _, a in ipairs({ ... }) do
		args = args .. " " .. a
	end
	local asyncrun =
		[[ call asyncrun#run( "!", { "mode": "terminal", "pos": "right", "name": "goldsmith-terminal", "focus": v:false }, "%s %s") ]]
	vim.api.nvim_command(string.format(asyncrun, cmd, args))
end

return M

