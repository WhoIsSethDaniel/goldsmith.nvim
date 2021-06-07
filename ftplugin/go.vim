if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

function s:GoDocComplete(A,C,P) abort
	let l:dir = expand('%:p:h')
	return luaeval("require'goldsmith.godoc'.complete(_A[1], _A[2], _A[3], _A[4])", [l:dir, a:A, a:C, a:P])
endfunction

" treesitter-based navigation
nnoremap <silent> <Plug>(goldsmith-next-function) <cmd>lua require'goldsmith.treesitter.navigate'.goto_next_function()<CR> 
nnoremap <silent> <Plug>(goldsmith-prev-function) <cmd>lua require'goldsmith.treesitter.navigate'.goto_prev_function()<CR> 
nnoremap <silent> <Plug>(goldsmith-function-loclist) <cmd>lua require'goldsmith.treesitter.navigate'.put_functions_in_list(false)<CR> 
nnoremap <silent> <Plug>(goldsmith-function-loclist-open) <cmd>lua require'goldsmith.treesitter.navigate'.put_functions_in_list(true)<CR> 

" diagnostic toggling
nnoremap <silent> <Plug>(goldsmith-toggle-diag-underline) <cmd>lua require'goldsmith.lsp.diagnostics'.toggle_underline()<CR>
nnoremap <silent> <Plug>(goldsmith-toggle-diag-signs) <cmd>lua require'goldsmith.lsp.diagnostics'.toggle_signs()<CR>
nnoremap <silent> <Plug>(goldsmith-toggle-diag-vtext) <cmd>lua require'goldsmith.lsp.diagnostics'.toggle_virtual_text()<CR>
nnoremap <silent> <Plug>(goldsmith-toggle-diag-update_in_insert) <cmd>lua require'goldsmith.lsp.diagnostics'.toggle_update_in_insert()<CR>
nnoremap <silent> <Plug>(goldsmith-diag-off) <cmd>lua require'goldsmith.lsp.diagnostics'.turn_off_diagnostics()<CR>
nnoremap <silent> <Plug>(goldsmith-diag-on) <cmd>lua require'goldsmith.lsp.diagnostics'.turn_on_diagnostics()<CR>

command! -nargs=+ -complete=customlist,s:GoDocComplete GoDoc lua require('goldsmith.godoc').view(<f-args>)

autocmd BufWritePre <buffer> lua require'goldsmith.imports'.goimports(1000)

let &cpo = s:cpo_save
unlet s:cpo_save
