local M = {}

local CONFIG = {
  goimports = {
    run_on_save = true,
    timeout = 1000,
  },
  goalt = {
    use_current_window = false,
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
  revive = {
    config_file = 'revive.toml',
  },
  format = {
    max_line_length = 120,
    run_on_save = true,
  },
  highlight = {
    current_symbol = true
  },
  codelens = {
    show = true
  },
  gopls = {},
  null = {},
}

function M.setup(user_config)
  CONFIG = vim.tbl_deep_extend('force', CONFIG, user_config or {})
end

function M.get(key)
  return CONFIG[key]
end

function M.set(grp, key, val)
  CONFIG[grp][key] = val
end

function M.dump()
  print(vim.inspect(CONFIG))
end

return M
