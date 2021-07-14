local tools = require("goldsmith.tools")

local health_start = vim.fn["health#report_start"]
local health_ok = vim.fn["health#report_ok"]
local health_error = vim.fn["health#report_error"]
local health_warn = vim.fn["health#report_warn"]

local M = {}

function M.tool_check()
	health_start("Tool Check")

	local check = tools.check()
	for _, tool in ipairs(tools.names()) do
		if check[tool].exec == "" then
			health_warn(string.format("%s: MISSING", tool), { check[tool].not_found })
		else
			health_ok(string.format("%s: FOUND at %s (%s)", tool, check[tool].exec, check[tool].version))
		end
	end
end

function M.check()
	M.tool_check()
end

return M
