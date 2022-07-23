if exists('g:goldsmith_loaded_install')
    finish
endif
let g:goldsmith_loaded_install = 1

let s:cpo_save = &cpo
set cpo&vim

function s:GoInstallComplete(A,C,P) abort
    return luaeval("require'goldsmith.cmds.installbin'.complete(_A[1], _A[2], _A[3])", [a:A, a:C, a:P])
endfunction

command! -nargs=* -complete=custom,s:GoInstallComplete GoInstallBinaries lua require'goldsmith.cmds.installbin'.run({<f-args>})

" highlights for :GoCoverage
hi def link goCoverageNormal Comment
hi def link goCoverageCovered MoreMsg
hi def link goCoverageNotCovered ErrorMsg

let &cpo = s:cpo_save
unlet s:cpo_save
