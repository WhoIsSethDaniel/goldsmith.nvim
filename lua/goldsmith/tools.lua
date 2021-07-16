local M = {}

local TOOLS = {
	go = {
		status = "expected",
		not_found = { "This is required" },
		get_version = function(cmd)
			local out = vim.fn.system(cmd .. " version")
			return string.match(out, " go([%d%.]+)")
		end,
	},
	gopls = {
		status = "install",
		location = "golang.org/x/tools/gopls",
		tag = "latest",
		not_found = {
			"If you are using lspinstall this is expected",
			"If not, you can install with ':GoInstallBinaries gopls'",
		},
		get_version = function(cmd)
			local out = vim.fn.system(cmd .. " version")
			return string.match(out, "@v([%d%.]+)")
		end,
	},
	["efm-langserver"] = {
		status = "install",
		location = "github.com/mattn/efm-langserver",
		tag = "latest",
		not_found = {
			"If you are using lspinstall this is expected",
			"If not, you can install with ':GoInstallBinaries efm-langserver'",
		},
		get_version = function(cmd)
			local out = vim.fn.system(cmd .. " -v")
			return string.match(out, "efm%-langserver ([%d%.]+)")
		end,
	},
	gomodifytags = {
		status = "install",
		location = "github.com/fatih/gomodifytags",
		tag = "latest",
		not_found = {
			"Struct tag manipulation will not work. i.e. :GoAddTags / :GoRemoveTags, etc...",
			"You can install with ':GoInstallBinaries gomodifytags'",
		},
	},
	gotests = {
		status = "install",
		location = "github.com/cweill/gotests/gotests",
		tag = "latest",
		not_found = { "This tool is not currently used" },
	},
	golines = {
		status = "install",
		location = "github.com/segmentio/golines",
		tag = "latest",
		not_found = { "This tool is not currently used" },
		get_version = function(cmd)
			local out = vim.fn.system(cmd .. " --version")
			return string.match(out, "v([%d%.]+)")
		end,
	},
	staticcheck = {
		status = "install",
		location = "honnef.co/go/tools/cmd/staticcheck",
		tag = "latest",
		not_found = { "This tool is not currently used" },
		get_version = function(cmd)
			local out = vim.fn.system(cmd .. " -version")
			return string.match(out, "%(v([%d%.]+)%)")
		end,
	},
	revive = {
		status = "install",
		location = "github.com/mgechev/revive",
		tag = "latest",
		not_found = { "This tool is not currently used" },
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
		if result[tool].exec == "" or result[tool].get_version == nil then
			result[tool].version = "unknown"
		else
			result[tool].version = result[tool].get_version(result[tool].exec)
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
