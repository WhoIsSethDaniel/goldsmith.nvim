if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

function s:GoDocComplete(A,C,P) abort
	return luaeval("require'goldsmith.cmds.doc'.complete(_A[1], _A[2], _A[3])", [a:A, a:C, a:P])
endfunction

function s:TagAction(act,line1,line2,count,...) abort
    if a:act ==? 'add'
        return luaeval("require'goldsmith.cmds.tags'.add(_A[1],_A[2],_A[3],_A[4])", [a:line1, a:line2, a:count, a:000])
    elseif a:act ==? 'remove'
        return luaeval("require'goldsmith.cmds.tags'.remove(_A[1],_A[2],_A[3],_A[4])", [a:line1, a:line2, a:count, a:000])
    endif
endfunction

command! -nargs=+ -complete=custom,s:GoDocComplete GoDoc lua require'goldsmith.cmds.doc'.run(<f-args>)
command! -nargs=0 GoImports lua require'goldsmith.cmds.imports'.run(1)
command! -nargs=0 GoFormat lua require'goldsmith.cmds.format'.run()
command! -nargs=* GoBuild lua require'goldsmith.cmds.build'.run(<f-args>)
command! -nargs=* GoRun lua require'goldsmith.cmds.run'.run(<f-args>)
command! -nargs=* GoGet lua require'goldsmith.cmds.get'.run(<f-args>)
command! -nargs=* GoInstall lua require'goldsmith.cmds.install'.run(<f-args>)
command! -nargs=* GoTest lua require'goldsmith.cmds.test'.run(<f-args>)
command! -nargs=0 GoLint lua require'goldsmith.cmds.lint'.run()
command! -nargs=* -range GoAddTags call s:TagAction('add', <line1>, <line2>, <count>, <f-args>)
command! -nargs=* -range GoRemoveTags call s:TagAction('remove', <line1>, <line2>, <count>, <f-args>)
command! -nargs=0 -range GoClearTags call s:TagAction('remove', <line1>, <line2>, <count>)

lua require'goldsmith.configs.treesitter-textobjects'.setup()

augroup goldsmith_ft_go
  autocmd! * <buffer>
  autocmd BufWritePre <buffer> lua require'goldsmith.cmds.imports'.run(0)
  autocmd BufEnter    <buffer> lua require'goldsmith.buffer'.checkin()
augroup END

let &cpo = s:cpo_save
unlet s:cpo_save
