local M = {}

-- for now, these keys are a-ok
local ACCEPTED_KEYS = { 'pos', 'focus', 'cols', 'rows' }

function M.run(cmd, async_args, extra_args)
  -- turn the given table into a string that looks like
  -- a vim dictionary
  local dict = ''
  for _, k in ipairs(ACCEPTED_KEYS) do
    local v = async_args[k]
    if v ~= nil and type(v) ~= 'table' then
      if type(v) == 'boolean' and v == true then
        v = 'v:true'
      elseif type(v) == 'boolean' and v == false then
        v = 'v:false'
      else
        v = string.format('"%s"', v)
      end
      dict = string.format('%s "%s": %s,', dict, k, v)
    end
  end

  local asyncrun = [[ call asyncrun#run( "", { "mode": "terminal", %s }, "%s") ]]
  vim.api.nvim_command(string.format(asyncrun, dict, cmd))
end

return M
