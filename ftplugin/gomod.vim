if exists('b:did_ftplugin')
    finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpoptions
set cpoptions&vim

if g:goldsmith_config_ok == v:false
    echohl ErrorMsg
    echomsg 'Goldsmith: Errors with configuration. Goldsmith failed to initialize.'
    echohl None
    echoerr ''
    finish
endif

if g:goldsmith_is_setup == v:false
    if !luaeval("require'goldsmith'.init()")
        echohl ErrorMsg
        echomsg 'Goldsmith: Failed to initialize'
        echohl None
        echoerr ''
        finish
    endif
    let g:goldsmith_is_setup = v:true
endif

setlocal textwidth=0
setlocal noexpandtab
setlocal formatoptions-=t
setlocal comments=s1:/*,mb:*,ex:*/,://
setlocal commentstring=//\ %s

function s:GoDocComplete(A,C,P) abort
    return luaeval("require'goldsmith.cmds.doc'.doc_complete(_A[1], _A[2], _A[3])", [a:A, a:C, a:P])
endfunction

function s:GoHelpComplete(A,C,P) abort
    return luaeval("require'goldsmith.cmds.doc'.help_complete(_A[1], _A[2], _A[3])", [a:A, a:C, a:P])
endfunction

command! -nargs=0 GoModCheck lua require'goldsmith.cmds.mod'.check_for_upgrades()
command! -nargs=0 GoModTidy lua require'goldsmith.cmds.mod'.tidy()
command! -nargs=+ GoModReplace lua require'goldsmith.cmds.mod'.replace({<f-args>})
command! -nargs=+ GoModRetract lua require'goldsmith.cmds.mod'.retract({<f-args>})
command! -nargs=* GoModExclude lua require'goldsmith.cmds.mod'.exclude({<f-args>})
command! -nargs=0 GoFormat lua require'goldsmith.cmds.format'.run(true)
cabbrev GoModFmt GoFormat

" codelens
command! -nargs=0 GoCodeLensRun lua require'goldsmith.cmds.lsp'.run_codelens()
command! -nargs=0 GoCodeLensOn lua require'goldsmith.cmds.lsp'.turn_on_codelens()
command! -nargs=0 GoCodeLensOff lua require'goldsmith.cmds.lsp'.turn_off_codelens()

" documentation
command! -nargs=+ -complete=custom,s:GoDocComplete GoDoc lua require'goldsmith.cmds.doc'.run('doc', {<f-args>})
command! -nargs=1 -complete=custom,s:GoHelpComplete GoHelp lua require'goldsmith.cmds.doc'.run('help', {<f-args>})

augroup goldsmith_ft_gomod
    autocmd! * <buffer>
    autocmd CursorHold,InsertLeave <buffer> lua require'goldsmith.codelens'.maybe_run()
    autocmd BufWritePre <buffer> lua require'goldsmith.cmds.format'.run(false)
augroup END

lua require'goldsmith.buffer'.setup()

let &cpoptions = s:cpo_save
unlet s:cpo_save
