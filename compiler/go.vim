if exists('g:current_compiler')
    finish
endif
let g:current_compiler = 'go'

let s:cpo_save = &cpo
set cpo&vim

if exists(':CompilerSet') != 2
    command -nargs=* CompilerSet setlocal <args>
endif

let s:save_cpo = &cpo
set cpo-=C
if filereadable('makefile') || filereadable('Makefile')
    CompilerSet makeprg=make
else
    CompilerSet makeprg=go\ build
endif

CompilerSet errorformat=%-G#\ %.%#
CompilerSet errorformat+=%-G%.%#panic:\ %m
CompilerSet errorformat+=%Ecan\'t\ load\ package:\ %m
CompilerSet errorformat+=%A%\\%%(%[%^:]%\\+:\ %\\)%\\?%f:%l:%c:\ %m
CompilerSet errorformat+=%A%\\%%(%[%^:]%\\+:\ %\\)%\\?%f:%l:\ %m
CompilerSet errorformat+=%C%*\\s%m
CompilerSet errorformat+=%-G%.%#

let &cpo = s:cpo_save
unlet s:cpo_save
