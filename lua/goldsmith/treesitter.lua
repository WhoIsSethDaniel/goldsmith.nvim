local parsers = require 'nvim-treesitter.parsers'
local ts = vim.treesitter

local M = {}

local function find_all_functions(root, funcs)
  if root:child_count() == 0 then
    return
  end
  for node in root:iter_children() do
    local ntype = node:type()
    if ntype == 'function_declaration' or ntype == 'method_declaration' then
      local line, col = ts.get_node_range(node)
      local name
      if ntype == 'method_declaration' then
        name = ts.get_node_text(node:child(2), 0)
      else
        name = ts.get_node_text(node:child(1), 0)
      end
      local f = {
        -- node = node,
        name = name,
        line = line,
        col = col,
        type = ntype,
      }
      table.insert(funcs, f)
    end
    find_all_functions(node, funcs)
  end
end

function M.get_all_functions()
  local trees = parsers.get_parser():parse()
  local funcs = {}
  find_all_functions(trees[1]:root(), funcs)
  return funcs
end

local function find_all_modules(root, mods)
  if root:child_count() == 0 then
    return
  end
  for node in root:iter_children() do
    local ntype = node:type()
    local ptype = node:parent():type()
    if ntype == 'module_path' and ptype == 'require_spec' then
      table.insert(mods, ts.get_node_text(node, 0))
    end
    find_all_modules(node, mods)
  end
end

local function find_all_types(root, types)
  if root:child_count() == 0 then
    return
  end
  for node in root:iter_children() do
    local ntype = node:type()
    if ntype == 'type_declaration' or ntype == 'var_declaration' then
      local line, col = ts.get_node_range(node)
      local name = ts.get_node_text(node:child(1), 0)
      name = string.match(name, '^([^%s]+)')
      local f = {
        -- node = node,
        name = name,
        line = line,
        col = col,
      }
      table.insert(types, f)
    end
    find_all_functions(node, types)
  end
end

function M.get_all_types()
  local trees = parsers.get_parser():parse()
  local types = {}
  find_all_types(trees[1]:root(), types)
  return types
end

function M.get_all_modules()
  local trees = parsers.get_parser():parse()
  local mods = {}
  find_all_modules(trees[1]:root(), mods)
  return mods
end

function M.get_module_at_cursor()
  local function find_node(cnode)
    local parent = cnode:parent()
    if parent ~= nil and parent:type() == 'require_spec' then
      return parent
    elseif cnode ~= nil and cnode:type() == 'require_directive' then
      local l = unpack(vim.api.nvim_win_get_cursor(0))
      for node in cnode:iter_children() do
        local nl = ts.get_node_range(node)
        if node:type() == 'require_spec' and l == nl + 1 then
          return node
        end
      end
    end
  end

  local cnode = ts.get_node()
  if not cnode then
    return
  end

  local mod, v
  local mnode = find_node(cnode)
  if mnode == nil then
    return
  end
  for node in mnode:iter_children() do
    if node:type() == 'module_path' then
      mod = ts.get_node_text(node, 0)
    end
    if node:type() == 'version' then
      v = ts.get_node_text(node, 0)
    end
  end
  return { name = mod, version = v }
end

function M.get_current_function_name()
  local current_node = ts.get_node()
  if not current_node then
    return
  end
  local expr = current_node

  while expr do
    if expr:type() == 'function_declaration' or expr:type() == 'method_declaration' then
      break
    end
    expr = expr:parent()
  end

  if not expr then
    return
  end

  if expr:type() == 'function_declaration' then
    return ts.get_node_text(expr:child(1), 0)
  elseif expr:type() == 'method_declaration' then
    return ts.get_node_text(expr:child(2), 0)
  end
end

return M
