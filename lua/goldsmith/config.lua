local M = {}

local CONFIG = {
	godoc = {
		open_split = "vertical",
	},
	goimports = {
		run_on_save = true,
		timeout = 1000,
	},
	terminal = {
		pos = "right",
		focus = false,
	},
	tags = {
		default_tag = "json",
		transform = "snakecase",
		skip_unexported = false,
	},
}

local TOOLS = {
	go = {
		status = "expected",
		problem = "This is required",
	},
	gopls = {
		status = "install",
		location = "golang.org/x/tools/gopls",
		tag = "latest",
		problem = "If you are using lspinstall this is expected; install with ':GoInstallBinaries gopls'",
	},
	["efm-langserver"] = {
		status = "install",
		location = "github.com/mattn/efm-langserver",
		tag = "latest",
		problem = "If you are using lspinstall this is expected; install with ':GoInstallBinaries efm-langserver'",
	},
	gomodifytags = {
		status = "install",
		location = "github.com/fatih/gomodifytags",
		tag = "latest",
		problem = "Struct tag manipulation will not work. i.e. :GoAddTags / :GoRemoveTags, etc...",
	},
	gotests = {
		status = "install",
		location = "github.com/cweill/gotests/gotests",
		tag = "latest",
		problem = "This tool is not currently used",
	},
	golines = {
		status = "install",
		location = "github.com/segmentio/golines",
		tag = "latest",
		problem = "This tool is not currently used",
	},
}

-- check that tool exists and executable, also get its version
-- if possible
function M.tool_check(names)
	local result = {}
	local tools = names or M.tool_names()
	for _, tool in ipairs(tools) do
		result[tool] = M.tool_info()[tool]
		result[tool].exec = vim.fn.exepath(tool)
		if result[tool].extract_version == nil then
			result[tool].version = "unknown"
		else
			result[tool].version = result[tool].extract_version(result[tool].exec)
		end
	end
	return result
end

function M.tool_info()
	return TOOLS
end

function M.tool_names(attrs)
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

function M.setup(user_config)
	CONFIG = vim.tbl_deep_extend("force", CONFIG, user_config)
end

function M.get(key)
	return CONFIG[key]
end

function M.dump()
	print(vim.inspect(CONFIG))
end

return M
