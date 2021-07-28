local M = {}

local CONFIG = {
  goimports = {
    run_on_save = true,
    timeout = 1000,
  },
  tests = {},
  terminal = {
    pos = 'right',
    focus = false,
    height = 20,
    width = 80,
  },
  window = {
    pos = 'right',
    focus = true,
    height = 20,
    width = 80,
  },
  tags = {
    default_tag = 'json',
    transform = 'snakecase',
    skip_unexported = false,
  },
}

function M.setup(user_config)
  CONFIG = vim.tbl_deep_extend('force', CONFIG, user_config)
end

function M.get(key)
  return CONFIG[key]
end

function M.dump()
  print(vim.inspect(CONFIG))
end

return M
