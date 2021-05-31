if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

function s:GoDocComplete(Arglead,CmdLine,CursorPos) abort
	let l:dir = expand('%:p:h')
	return luaeval("require'goldsmith.godoc'.complete(_A[1], _A[2], _A[3], _A[4])", [l:dir, a:Arglead, a:CmdLine, a:CursorPos])
endfunction

nnoremap <silent> <Plug>(goldsmith-next-function) <cmd>lua require'goldsmith.treesitter.navigate'.goto_next_function()<CR> 
nnoremap <silent> <Plug>(goldsmith-prev-function) <cmd>lua require'goldsmith.treesitter.navigate'.goto_prev_function()<CR> 

command! -nargs=+ -complete=customlist,s:GoDocComplete GoDoc lua require('goldsmith.godoc').view(<f-args>)

autocmd BufWritePre <buffer> lua require'goldsmith.imports'.goimports(1000)
autocmd BufNew <buffer> lua require'goldsmith.lsp.diagnostics'.toggle_diagnostics()

let &cpo = s:cpo_save
unlet s:cpo_save
