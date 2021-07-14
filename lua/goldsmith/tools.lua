local M = {}

local TOOLS = {
	go = {
		status = "expected",
		not_found = "This is required",
	},
	gopls = {
		status = "install",
		location = "golang.org/x/tools/gopls",
		tag = "latest",
		not_found = "If you are using lspinstall this is expected; install with ':GoInstallBinaries gopls'",
	},
	["efm-langserver"] = {
		status = "install",
		location = "github.com/mattn/efm-langserver",
		tag = "latest",
		not_found = "If you are using lspinstall this is expected; install with ':GoInstallBinaries efm-langserver'",
	},
	gomodifytags = {
		status = "install",
		location = "github.com/fatih/gomodifytags",
		tag = "latest",
		not_found = "Struct tag manipulation will not work. i.e. :GoAddTags / :GoRemoveTags, etc...",
	},
	gotests = {
		status = "install",
		location = "github.com/cweill/gotests/gotests",
		tag = "latest",
		not_found = "This tool is not currently used",
	},
	golines = {
		status = "install",
		location = "github.com/segmentio/golines",
		tag = "latest",
		not_found = "This tool is not currently used",
	},
}

-- check that tool exists and executable, also get its version
-- if possible
function M.check(names)
	local result = {}
	local tools = names or M.names()
	for _, tool in ipairs(tools) do
		result[tool] = M.info(tool)
		result[tool].exec = vim.fn.exepath(tool)
		if result[tool].find_version == nil then
			result[tool].version = "unknown"
		else
			result[tool].version = result[tool].find_version(result[tool].exec)
		end
	end
	return result
end

function M.info(name)
	return TOOLS[name]
end

function M.names(attrs)
	local names = {}
	for k, v in pairs(TOOLS) do
		if attrs == nil then
			table.insert(names, k)
		else
			for ak, av in pairs(attrs) do
				if v[ak] == av then
					table.insert(names, k)
				end
			end
		end
	end
	return names
end

return M
