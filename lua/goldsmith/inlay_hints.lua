-- I could say this was 'inspired' by rust-tools, but it was mostly copied from rust-tools.

local config = require 'goldsmith.config'
local ac = require 'goldsmith.autoconfig'

local M = {}

function M.maybe_run()
  if ac.all_servers_are_running() then
    if config.get('inlay_hints', 'enable') == true then
      M.set_inlay_hints()
    end
  end
end

local function get_params()
  local params = vim.lsp.util.make_given_range_params()
  params['range']['start']['line'] = 0
  params['range']['end']['line'] = vim.api.nvim_buf_line_count(0) - 1
  return params
end

local namespace = vim.api.nvim_create_namespace 'experimental/inlayHints'
local enabled = nil

local function parseHints(result)
  local map = {}

  if type(result) ~= 'table' then
    return {}
  end
  for _, value in pairs(result) do
    local range = value.position
    local line = value.position.line
    local column = value.position.character
    local label = value.label[1]['value']
    local kind = value.kind

    local function add_line()
      if map[line] ~= nil then
        table.insert(map[line], { column = column, label = label, kind = kind, range = range })
      else
        map[line] = { { label = label, kind = kind, range = range, column = column } }
      end
    end

    add_line()
  end
  return map
end

local function handler(err, result, ctx)
  if err then
    return
  end
  local opts = {
    -- prefix for parameter hints
    -- default: "<-"
    parameter_hints_prefix = '<- ',

    -- prefix for all the other hints (type, chaining)
    -- default: "=>"
    other_hints_prefix = '=> ',

    -- whether to align to the length of the longest line in the file
    max_len_align = false,

    -- padding from the left if max_len_align is true
    max_len_align_padding = 1,

    -- whether to align to the extreme right or not
    right_align = false,

    -- padding from the right if right_align is true
    right_align_padding = 7,

    -- The color of the hints
    highlight = 'Comment',
  }

  local bufnr = ctx.bufnr

  if vim.api.nvim_get_current_buf() ~= bufnr then
    return
  end

  M.disable_inlay_hints()

  local parsed = parseHints(result)

  for key, value in pairs(parsed) do
    local virt_text = ''
    local line = tonumber(key)

    local current_line = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]

    if current_line then
      local param_hints = {}
      local other_hints = {}

      -- segregate parameter hints and other hints
      for _, value_inner in ipairs(value) do
        if value_inner.kind == 2 then
          table.insert(param_hints, value_inner.label)
        end

        if value_inner.kind == 1 then
          table.insert(other_hints, value_inner)
        end
      end

      -- show parameter hints inside brackets with commas and a thin arrow
      if not vim.tbl_isempty(param_hints) and opts.show_parameter_hints then
        virt_text = virt_text .. opts.parameter_hints_prefix .. '('
        for i, value_inner_inner in ipairs(param_hints) do
          virt_text = virt_text .. value_inner_inner:sub(1, -2)
          if i ~= #param_hints then
            virt_text = virt_text .. ', '
          end
        end
        virt_text = virt_text .. ') '
      end

      -- show other hints with commas and a thicc arrow
      if not vim.tbl_isempty(other_hints) then
        virt_text = virt_text .. opts.other_hints_prefix
        for i, value_inner_inner in ipairs(other_hints) do
          if value_inner_inner.kind == 2 and opts.show_variable_name then
            local char_start = value_inner_inner.range.start.character
            local char_end = value_inner_inner.range['end'].character
            local variable_name = string.sub(current_line, char_start + 1, char_end)
            virt_text = virt_text .. variable_name .. ': ' .. value_inner_inner.label
          else
            if string.sub(value_inner_inner.label, 1, 2) == ': ' then
              virt_text = virt_text .. value_inner_inner.label:sub(3)
            else
              virt_text = virt_text .. value_inner_inner.label
            end
          end
          if i ~= #other_hints then
            virt_text = virt_text .. ', '
          end
        end
      end

      if virt_text ~= '' then
        vim.api.nvim_buf_set_extmark(bufnr, namespace, line, 0, {
          virt_text_pos = 'eol',
          virt_text = {
            { virt_text, opts.highlight },
          },
          hl_mode = 'combine',
        })
      end

      enabled = true
    end
  end
end

function M.toggle_inlay_hints()
  if enabled then
    M.disable_inlay_hints()
  else
    M.set_inlay_hints()
  end
  enabled = not enabled
end

function M.disable_inlay_hints()
  -- clear namespace which clears the virtual text as well
  vim.api.nvim_buf_clear_namespace(0, namespace, 0, -1)
end

function M.mk_handler(fn)
  return function(...)
    local config_or_client_id = select(4, ...)
    local is_new = type(config_or_client_id) ~= 'number'
    if is_new then
      fn(...)
    else
      local err = select(1, ...)
      local method = select(2, ...)
      local result = select(3, ...)
      local client_id = select(4, ...)
      local bufnr = select(5, ...)
      local config = select(6, ...)
      fn(err, result, { method = method, client_id = client_id, bufnr = bufnr }, config)
    end
  end
end

function M.set_inlay_hints()
  vim.lsp.buf_request(0, 'textDocument/inlayHint', get_params(), M.mk_handler(handler))
end

return M
