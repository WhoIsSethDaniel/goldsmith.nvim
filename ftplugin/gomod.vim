if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

command! -nargs=0 GoModCheck lua require'goldsmith.mod'.check_for_upgrades()
command! -nargs=0 GoModTidy lua require'goldsmith.mod'.tidy()
command! -nargs=0 GoModFmt lua require'goldsmith.mod'.format()

let &cpo = s:cpo_save
unlet s:cpo_save
