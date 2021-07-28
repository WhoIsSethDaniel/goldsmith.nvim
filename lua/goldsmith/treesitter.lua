local parsers = require'nvim-treesitter.parsers'
local ts_utils = require 'nvim-treesitter.ts_utils'

local M = {}

local function find_all_functions(root, funcs)
  if root:child_count() == 0 then
    return
  end
  for node in root:iter_children() do
    local ntype = node:type()
    if ntype == 'function_declaration' or ntype == 'method_declaration' then
      table.insert(funcs, (ts_utils.get_node_text(node:child(1)))[1])
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

function M.get_current_function_name()
  local current_node = ts_utils.get_node_at_cursor()
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

  return (ts_utils.get_node_text(expr:child(1)))[1]
end

return M
