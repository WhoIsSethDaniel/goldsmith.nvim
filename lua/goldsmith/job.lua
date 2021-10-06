local log = require 'goldsmith.log'
local wb = require 'goldsmith.winbuf'
local go = require 'goldsmith.go'

local M = {}

local running_jobs = {}

local process_acts = {
  -- generic compile error
  {
    on = 'stderr_output',
    match = '^(.+%.go):(%d+):%d+: (.*)$',
    act = function(state, args)
      return {
        file = args.matches[1],
        line = args.matches[2],
        mess = args.matches[3],
      }
    end,
  },
  -- capture the panic message
  {
    on = 'stderr_output',
    match = '^panic: (.*)$',
    act = function(state, args)
      if string.match(args.matches[1], '^%s*$') ~= nil then
        return
      end
      state['last_panic'] = args.matches[1]
    end,
  },
  -- capture file/line number of panic
  {
    on = 'stderr_output',
    match = '^\t(/.+%.go):(%d+) %+0x.*$',
    act = function(state, args)
      local m = {
        mess = state['last_panic'] or 'panic',
        file = args.matches[1],
        line = args.matches[2],
      }
      m.file = string.sub(m.file, string.len(vim.fn.getcwd()) + 2)
      return m
    end,
  },
}

function M.check_for_errors(actions, output)
  local mod = go.module_path()
  if mod == nil then
    log.warn('Testing', 'Cannot determine import path for current project.')
    mod = ''
  end
  local qflist = {}
  local state = {}
  for _, j in ipairs(output) do
    for _, ta in ipairs(actions) do
      if ta.on == j.Action then
        local matches = { string.match(j.Output, ta.match) }
        if #matches > 0 then
          local m = ta.act(state, { j = j, module = mod, matches = matches })
          if m ~= nil and m.file ~= nil then
            local f = vim.fn.fnamemodify(m.file, ':p')
            if vim.fn.filereadable(vim.fn.escape(f, ' *?')) ~= 0 then
              table.insert(qflist, {
                filename = f,
                lnum = m.line,
                col = 1,
                text = m.mess,
                type = 'E',
              })
            end
          end
        end
      end
    end
  end
  -- sort and uniq
  table.sort(qflist, function(a, b)
    if a.filename == b.filename then
      return a.lnum < b.lnum
    end
    return a.filename < b.filename
  end)
  local prev
  return vim.tbl_filter(function(e)
    if prev == nil then
      prev = e
      return true
    end
    if prev.filename == e.filename and prev.lnum == e.lnum and prev.text == e.text then
      prev = e
      return false
    end
    prev = e
    return true
  end, qflist)
end

local function wrap(name, opts, f)
  local wrapped = opts[name]
  opts[name] = function(a, b, c)
    f(a, b, c)
    if wrapped ~= nil then
      wrapped(a, b, c)
    end
  end
end

function M.run(cmd, ...)
  local opts = vim.tbl_deep_extend('force', {}, ...)

  log.debug('Job', function()
    return 'cmd: ' .. vim.inspect(cmd)
  end)
  log.debug('Job', function()
    return 'opts: ' .. vim.inspect(opts)
  end)

  if opts['check_for_errors'] then
    local stderr, stdout = { '' }, { '' }
    wrap('on_stderr', opts, function(id, d)
      local data = d
      local last = table.remove(data, 1)
      local len = #stderr
      stderr[len] = stderr[len] .. last
      vim.list_extend(stderr, data)
    end)
    wrap('on_stdout', opts, function(id, d)
      local data = d
      local last = table.remove(data, 1)
      local len = #stdout
      stdout[len] = stdout[len] .. last
      vim.list_extend(stdout, data)
    end)
    wrap('on_exit', opts, function(id, code, type)
      local out = {}
      for _, v in ipairs { stdout, stderr } do
        for _, line in ipairs(v) do
          line = string.match(line, '^(.*)[%c%s]+$') or ''
          table.insert(out, { Output = line, Action = 'stderr_output' })
        end
      end
      local qflist = M.check_for_errors(process_acts, out)
      if #qflist > 0 then
        vim.fn.setqflist({}, ' ', { nr = '$', items = qflist, title = table.concat(cmd, ' ') })
        local w = vim.api.nvim_get_current_win()
        vim.cmd [[ copen ]]
        vim.api.nvim_set_current_win(w)
        vim.api.nvim_command 'doautocmd QuickFixCmdPost'
      end
    end)
  end

  local job
  if opts['terminal'] then
    local winbuf = wb.create_winbuf(
      vim.tbl_deep_extend('force', opts, { reuse = 'job_terminal', destroy = true, keymap = 'terminal', create = true })
    )
    local w = vim.api.nvim_get_current_win()

    vim.api.nvim_set_current_win(winbuf.win)
    job = vim.fn.termopen(cmd, opts)
    vim.api.nvim_set_current_win(w)
  else
    wrap('on_exit', opts, function(id, code, type)
      running_jobs[id] = nil
    end)
    job = vim.fn.jobstart(cmd, opts)
    running_jobs[job] = cmd
  end

  return job
end

function M.running_jobs()
  return running_jobs
end

return M
