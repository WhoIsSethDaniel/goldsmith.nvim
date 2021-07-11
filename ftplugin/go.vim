if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

function s:GoDocComplete(A,C,P) abort
	return luaeval("require'goldsmith.cmds.doc'.complete(_A[1], _A[2], _A[3])", [a:A, a:C, a:P])
endfunction

command! -nargs=+ -complete=custom,s:GoDocComplete GoDoc lua require'goldsmith.cmds.doc'.run(<f-args>)
command! -nargs=0 GoImports lua require'goldsmith.cmds.imports'.run(1)
command! -nargs=0 GoFormat lua require'goldsmith.cmds.format'.run()
command! -nargs=* GoBuild lua require'goldsmith.cmds.build'.run(<f-args>)
command! -nargs=* GoRun lua require'goldsmith.cmds.run'.run(<f-args>)
command! -nargs=* GoGet lua require'goldsmith.cmds.get'.run(<f-args>)
command! -nargs=* GoInstall lua require'goldsmith.cmds.install'.run(<f-args>)

lua require'goldsmith.configs.treesitter-textobjects'.setup()

augroup goldsmith_ft_go
  autocmd! * <buffer>
  autocmd BufWritePre <buffer> lua require'goldsmith.cmds.imports'.run(0)
  autocmd BufEnter    <buffer> lua require'goldsmith.buffer'.checkin()
augroup END

let &cpo = s:cpo_save
unlet s:cpo_save
