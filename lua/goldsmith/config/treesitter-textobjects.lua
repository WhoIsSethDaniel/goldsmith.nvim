local to = require("nvim-treesitter.configs")

local M = {}

function M.setup()
	to.setup({
		textobjects = {
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["af"] = { go = "@function.outer" },
					["if"] = { go = "@function.inner" },
					["ac"] = { go = "@comment.outer" },
				},
			},
			move = {
				enable = true,
				set_jumps = true,
				goto_next_start = {
					["]]"] = { go = "@function.outer" },
				},
				goto_previous_start = {
					["[["] = { go = "@function.outer" },
				},
			},
		},
	})
end

return M
