local uv = require'luv'
local api = vim.api

local M = {
    buf_nr = -1
}

local function goenv(envname)
    local f = io.popen("go env " .. string.upper(envname))
    local val = f:lines()()
    f:close()
    return val
end

local function godoc(...)
    local args = ''
    for _, a in ipairs{...} do
        args = args .. ' ' .. a
    end
    local f = io.popen(string.format("go doc %s", args))
    local content = f:lines('a')()
    f:close()
    return content
end

function M.complete(workdir,arglead,cmdline,cursorPos)
    uv.chdir(workdir)

    local dirs = {}
    local goroot = goenv("goroot")
    dirs[#dirs+1] = string.format("%s/src", goroot)
    dirs[#dirs+1] = goenv("gomodcache")
    local gomod = goenv("gomod")
    if gomod ~= '/dev/null' and gomod ~= 'NUL' and gomod ~= '' then
        local path = string.match(gomod, '^(.+)/go%.mod$')
        dirs[#dirs+1] = path
    end
    local gopath = goenv("gopath")
    for p in string.gmatch(gopath, "([%w"..package.config:sub(1,1).."]+)[;:]*") do
        dirs[#dirs+1] = p
    end

    local base, last = string.match(arglead, '(%g+)/(%g*)$')
    if base == nil then
        last = arglead
    end

    local alldirs = {}
    for _, dir in ipairs(dirs) do
        if base == nil then
            alldirs[#alldirs+1] = dir
        else
            alldirs[#alldirs+1] = string.format("%s/%s", dir, base)
        end
    end

    local possibles = {}
    for _, dir in ipairs(alldirs) do
        local handle = uv.fs_scandir(dir)
        if handle == nil then
            goto continue_out
        end
        while true do
            local name, type = uv.fs_scandir_next(handle)
            if name == nil then
                break
            end
            if type == 'file' and string.find(name, '%.go$') == nil then
                goto continue_in
            end
            -- cleanup name by removing
            -- versions, and
            -- .go extensions
            name = (string.match(name, '^(.*)@') or name)
            name = (string.match(name, '^(.*)%.go$') or name)
            if last == nil then
                possibles[#possibles+1] = name
            else
                local ndx = string.find(name, "^" .. last)
                if ndx == 1 then
                    if base == nil then
                        possibles[#possibles+1] = name
                    else
                        possibles[#possibles+1] = string.format("%s/%s", base, name)
                    end
                end
            end
            ::continue_in::
        end
        ::continue_out::
    end
    return possibles
end

function M.view(...)
    local doc = godoc(...)

    -- Much of the below is taken from vim-go's code, and
    -- translated to Lua
    if (M.buf_nr == -1) then
        vim.cmd('new')
        M.buf_nr = api.nvim_get_current_buf()
        api.nvim_buf_set_name(M.buf_nr, "[Go Documentation]")
    elseif vim.fn.bufwinnr(M.buf_nr) == -1 then
        vim.cmd('split')
        api.nvim_win_set_buf(0,M.buf_nr)
    elseif vim.fn.bufwinnr(M.buf_nr) ~= vim.fn.bufwinnr('%') then
        vim.cmd(vim.fn.bufwinnr(M.buf_nr) .. 'wincmd w')
    end

    api.nvim_buf_set_option(0, 'filetype', 'godoc')
    api.nvim_buf_set_option(0, 'bufhidden', 'delete')
    api.nvim_buf_set_option(0, 'buftype', 'nofile')
    api.nvim_buf_set_option(0, 'swapfile', false)
    api.nvim_buf_set_option(0, 'buflisted', false)
    api.nvim_win_set_option(0, 'cursorline', false)
    api.nvim_win_set_option(0, 'cursorcolumn', false)
    api.nvim_win_set_option(0, 'number', false)

    vim.cmd([[
        setlocal modifiable
        %delete _
    ]])
    api.nvim_buf_set_lines(M.buf_nr,-1,-1,false,vim.split(doc, "\n"))
    vim.cmd([[
        silent $delete _
        setlocal nomodifiable
        silent normal! gg
    ]])
    vim.cmd([[
        noremap <buffer> <silent> <CR> :<C-U>close<CR>
        noremap <buffer> <silent> q :<C-U>close<CR>
        noremap <buffer> <silent> <Esc> :<C-U>close<CR>
        nnoremap <buffer> <silent> <Esc>[ <Esc>[
    ]])
end

return M
