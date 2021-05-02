" nnoremap <buffer> <silent> K :GoDoc<cr>

function s:GoDocComplete(Arglead,CmdLine,CursorPos) abort
	let l:dir = expand('%:p:h')
	return luaeval("require'godoc'.complete(_A[1], _A[2], _A[3], _A[4])", [l:dir, a:Arglead, a:CmdLine, a:CursorPos])
endfunction

command! -nargs=+ -complete=customlist,s:GoDocComplete GoDoc lua require('godoc').view(<f-args>)
