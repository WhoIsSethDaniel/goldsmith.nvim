if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

setlocal textwidth=0
setlocal noexpandtab
setlocal formatoptions-=t
setlocal comments=s1:/*,mb:*,ex:*/,://
setlocal commentstring=//\ %s

command! -nargs=0 GoModCheck lua require'goldsmith.mod'.check_for_upgrades()
command! -nargs=0 GoModTidy lua require'goldsmith.mod'.tidy()
command! -nargs=0 GoModFmt lua require'goldsmith.mod'.format()
command! -nargs=+ GoModReplace lua require'goldsmith.mod'.replace({<f-args>})

" codelens
command! -nargs=0 GoCodeLensRun lua require'goldsmith.cmds.lsp'.run_codelens()
command! -nargs=0 GoCodeLensOn lua require'goldsmith.cmds.lsp'.turn_on_codelens()
command! -nargs=0 GoCodeLensOff lua require'goldsmith.cmds.lsp'.turn_off_codelens()

augroup goldsmith_ft_gomod
  autocmd! * <buffer>
  autocmd CursorHold,InsertLeave <buffer> lua require'goldsmith.codelens'.update()
augroup END

let &cpo = s:cpo_save
unlet s:cpo_save
