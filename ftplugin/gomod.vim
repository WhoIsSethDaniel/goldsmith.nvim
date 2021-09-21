if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

if g:goldsmith_is_setup == v:false
  echoerr 'Goldsmith: Cannot setup current buffer. Goldsmith failed to initialize.'
  finish
endif

setlocal textwidth=0
setlocal noexpandtab
setlocal formatoptions-=t
setlocal comments=s1:/*,mb:*,ex:*/,://
setlocal commentstring=//\ %s

command! -nargs=0 GoModCheck lua require'goldsmith.cmds.mod'.check_for_upgrades()
command! -nargs=0 GoModTidy lua require'goldsmith.cmds.mod'.tidy()
command! -nargs=+ GoModReplace lua require'goldsmith.cmds.mod'.replace({<f-args>})
command! -nargs=+ GoModRetract lua require'goldsmith.cmds.mod'.retract({<f-args>})
command! -nargs=* GoModExclude lua require'goldsmith.cmds.mod'.exclude({<f-args>})
command! -nargs=0 GoFormat lua require'goldsmith.cmds.format'.run(1)
cabbrev GoModFmt GoFormat

" codelens
command! -nargs=0 GoCodeLensRun lua require'goldsmith.cmds.lsp'.run_codelens()
command! -nargs=0 GoCodeLensOn lua require'goldsmith.cmds.lsp'.turn_on_codelens()
command! -nargs=0 GoCodeLensOff lua require'goldsmith.cmds.lsp'.turn_off_codelens()

augroup goldsmith_ft_gomod
  autocmd! * <buffer>
  autocmd CursorHold,InsertLeave <buffer> lua require'goldsmith.codelens'.update()
  autocmd BufWritePre <buffer> lua require'goldsmith.cmds.format'.run(0)
augroup END

lua require'goldsmith.buffer'.setup()

let &cpo = s:cpo_save
unlet s:cpo_save
