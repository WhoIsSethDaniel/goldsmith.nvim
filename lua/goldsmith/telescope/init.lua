local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
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

for _, p in ipairs(go_pickers) do
  M[p.name] = function(opts)
    if not buffer.is_managed_buffer() then
      log.warn('Telescope', 'Goldsmith telescope extensions may not be run on non-Goldsmith managed buffers.')
      return
    end
    pickers.new(opts, {
      prompt_title = p.title,
      finder = finders.new_table {
        results = p.f('./...'),
      },
      sorter = conf.file_sorter(opts),
    }):find()
  end
end

return M
