local M = {}

local CONFIG = {
  godoc = {
    open_split = 'vertical',
  },
  goimports = {
    run_on_save = true,
    timeout = 1000,
  },
  terminal = {
    pos = 'right',
    focus = false,
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
