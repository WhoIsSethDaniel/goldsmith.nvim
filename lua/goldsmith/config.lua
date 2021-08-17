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
  ['golangci-lint'] = {
    config_file = '.golangci.yml'
  },
  format = {
    max_line_length = 120,
    run_on_save = true,
  },
  highlight = {
    current_symbol = true,
  },
  codelens = {
    show = true,
  },
  gopls = {},
  null = {
    disabled = { 'revive', 'staticcheck' },
  },
}

local autoconfig = true

function M.turn_off_autoconfig()
  autoconfig = false
end

function M.autoconfig_is_on()
  return autoconfig
end

function M.setup(user_config)
  user_config = user_config or {}
  local ac = user_config['autoconfig']
  if ac ~= nil and type(ac) == 'boolean' and ac == false then
    autoconfig = false
  end
  user_config['autoconfig'] = nil
  CONFIG = vim.tbl_deep_extend('force', CONFIG, user_config)
end

function M.get(grp, key)
  if key == nil then
    return CONFIG[grp]
  else
    return CONFIG[grp][key]
  end
end

function M.set(grp, key, val)
  CONFIG[grp][key] = val
end

function M.dump()
  print(vim.inspect(CONFIG))
end

return M
