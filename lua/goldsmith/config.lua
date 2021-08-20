local M = {}

local function in_set(...)
  local vals = { ... }
  return function(v)
    return vim.tbl_contains(vals, v)
  end
end

local function is_positive()
  return function(v)
    return type(v) == 'number' and v > 0
  end
end

local terminal_valid = {
  pos = {
    'right',
    in_set('top', 'bottom', 'left', 'right'),
    'valid position',
  },
  focus = { false, 'b' },
  height = {
    20,
    is_positive(),
    'positive integer',
  },
  width = {
    80,
    is_positive(),
    'positive integer',
  },
}

local window_valid = {
  pos = {
    'right',
    in_set('top', 'bottom', 'left', 'right'),
    'valid position',
  },
  focus = { true, 'b' },
  height = {
    20,
    is_positive(),
    'positive integer',
  },
  width = {
    80,
    is_positive(),
    'positive integer',
  },
}

local function validate_action(maps)
  for k, v in pairs(maps) do
    if
      not in_set(
        'definition',
        'hover',
        'implementation',
        'signature_help',
        'add_workspace_folder',
        'remove_workspace_folder',
        'list_workspace_folders',
        'type_definition',
        'rename',
        'references',
        'code_action',
        'show_line_diagnostics',
        'goto_previous_diagnostic',
        'goto_next_diagnostic',
        'diagnostic_set_loclist',
        'format'
      )(v)
    then
      -- logging not available yet
      vim.api.nvim_err_writeln(string.format("Goldsmith: Valid: Mapping '%s' has unknown action '%s'", k, v))
    end
  end
end

local SPEC = {
  mappings = {
    ['gd'] = 'definition',
    ['K'] = 'hover',
    ['gi'] = 'implementation',
    ['<C-k>'] = 'signature_help',
    ['<leader>wa'] = 'add_workspace_folder',
    ['<leader>wr'] = 'remove_workspace_folder',
    ['<leader>wl'] = 'list_workspace_folders',
    ['<leader>D'] = 'type_definition',
    ['<leader>rn'] = 'rename',
    ['<leader>gr'] = 'references',
    ['<leader>ca'] = 'code_action',
    ['<leader>e'] = 'show_line_diagnostics',
    ['[d'] = 'goto_previous_diagnostic',
    [']d'] = 'goto_next_diagnostic',
    ['<leader>q'] = 'diagnostic_set_loclist',
    ['<leader>f'] = 'format',
  },
  internal = {
    debug = { false, 'b' },
  },
  completion = {
    omni = { false, 'b' },
  },
  goimports = {
    run_on_save = { true, 'b' },
    timeout = { 1000, 'n' },
  },
  gobuild = terminal_valid,
  gorun = terminal_valid,
  gotest = terminal_valid,
  goget = terminal_valid,
  goinstall = terminal_valid,
  godoc = window_valid,
  goalt = vim.tbl_extend('error', window_valid, { use_current_window = { false, 'b' } }),
  jump = vim.tbl_extend('error', window_valid, { use_current_window = { true, 'b' } }),
  terminal = terminal_valid,
  window = window_valid,
  tags = {
    default_tag = { 'json', 's' },
    transform = {
      'snakecase',
      in_set('snakecase', 'camelcase', 'lispcase', 'pascalcase', 'keep'),
      'valid transformation',
    },
    skip_unexported = { false, 'b' },
  },
  ['golangci-lint'] = {
    config_file = { nil, 's' },
  },
  format = {
    max_line_length = {
      120,
      is_positive(),
      'positive integer',
    },
    run_on_save = { true, 'b' },
  },
  highlight = {
    current_symbol = { true, 'b' },
  },
  codelens = {
    show = { true, 'b' },
  },
  revive = {
    config_file = { nil, 's' },
  },
  tests = {
    template = { nil, 's' },
    template_dir = { nil, 's' },
    template_params_dir = { nil, 's' },
  },
  gopls = {},
  null = {
    disabled = {
      { 'staticcheck' },
      function(v)
        if type(v) == 'boolean' then
          return true
        end
        if type(v) ~= 'table' then
          return false
        end
        for _, s in ipairs(v) do
          local vals = { 'staticcheck', 'golines', 'golangci-lint', 'revive' }
          if not vim.tbl_contains(vals, s) then
            return false
          end
        end
        return true
      end,
      'either boolean or valid list of services',
    },
  },
}

local _config = {}
local _defaults = {}
local _validate = {}

local autoconfig = true

function M.turn_off_autoconfig()
  autoconfig = false
end

function M.autoconfig_is_on()
  return autoconfig
end

local function defaults()
  if not vim.tbl_isempty(_defaults) then
    return _defaults
  end
  for grp, val in pairs(SPEC) do
    _defaults[grp] = {}
    for k, v in pairs(val) do
      _defaults[grp][k] = v[1]
    end
  end
  return _defaults
end

local function user_validate(uc)
  for grp, val in pairs(SPEC) do
    if grp ~= 'mappings' then
      for k, v in pairs(val) do
        local vkey = grp .. '.' .. k
        local default = v[1]
        local value = uc[grp][k] or default
        local check = v[2]
        if type(check) == 'function' then
          _validate[vkey] = { value, check, v[3] }
        else
          if default == nil then
            _validate[vkey] = { value, check, true }
          else
            _validate[vkey] = { value, check }
          end
        end
      end
    end
  end
  return _validate
end

local function set_autoconfig(ac)
  if ac ~= nil and type(ac) == 'boolean' and ac == false then
    autoconfig = false
  end
end

local function combine_configs(user_config)
  local d = defaults()
  if user_config['mappings'] then
    d['mappings'] = {}
  end
  return vim.tbl_deep_extend('force', d, user_config)
end

local function all_config_keys()
  return vim.tbl_keys(defaults())
end

local function validate_config(c)
  local valid_keys = all_config_keys()
  local tl_key_validate = {}
  for _, uk in ipairs(vim.tbl_keys(c)) do
    tl_key_validate[uk] = {
      uk,
      function(v)
        return vim.tbl_contains(valid_keys, v)
      end,
      'valid configuration key',
    }
  end
  vim.validate(tl_key_validate)
  vim.validate(user_validate(c))
  validate_action(c['mappings'])
end

function M.setup(user_config)
  user_config = user_config or {}
  set_autoconfig(user_config['autoconfig'])
  user_config['autoconfig'] = nil
  _config = combine_configs(user_config)
  validate_config(_config)
end

function M.get(grp, key)
  if key == nil then
    return _config[grp]
  else
    return _config[grp][key]
  end
end

function M.set(grp, key, val)
  _config[grp][key] = val
end

function M.dump()
  require('goldsmith.log').debug('config', function()
    return vim.inspect(_config)
  end)
end

return M
