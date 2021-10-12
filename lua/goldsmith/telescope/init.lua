local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local make_entry = require 'telescope.make_entry'
local conf = require('telescope.config').values
local go = require 'goldsmith.go'
local log = require 'goldsmith.log'
local buffer = require 'goldsmith.buffer'
local coverage = require 'goldsmith.coverage'

local M = {}

local go_pickers = {
  { name = 'go_files', f = go.files, title = 'All Go Files' },
  { name = 'go_test_files', f = go.test_files, title = 'Go Test Files' },
  { name = 'go_code_files', f = go.code_files, title = 'Go Code Files' },
  { name = 'go_covered_files', f = coverage.files, title = 'Go Covered Files' },
}

local exports = {}
for _, p in ipairs(go_pickers) do
  M[p.name] = function(opts)
    opts = opts or {}
    if not buffer.is_managed_buffer() then
      log.warn('Telescope', 'Goldsmith telescope extensions may not be run on non-Goldsmith managed buffers.')
      return
    end
    pickers.new(opts, {
      previewer = conf.file_previewer(opts),
      prompt_title = p.title,
      finder = finders.new_table {
        results = p.f('./...'),
        entry_maker = make_entry.gen_from_file(),
      },
      sorter = conf.file_sorter(opts),
    }):find()
  end
  exports[p.name] = M[p.name]
end

function M.register()
  return telescope.register_extension { exports = exports }
end

return M
