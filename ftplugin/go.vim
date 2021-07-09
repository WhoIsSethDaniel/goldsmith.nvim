if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

function s:GoDocComplete(A,C,P) abort
	return luaeval("require'goldsmith.godoc'.complete(_A[1], _A[2], _A[3])", [a:A, a:C, a:P])
endfunction

" treesitter-based navigation
nnoremap <silent> <Plug>(goldsmith-next-function) <cmd>lua require'goldsmith.treesitter.navigate'.goto_next_function()<CR> 
nnoremap <silent> <Plug>(goldsmith-prev-function) <cmd>lua require'goldsmith.treesitter.navigate'.goto_prev_function()<CR> 
nnoremap <silent> <Plug>(goldsmith-function-loclist) <cmd>lua require'goldsmith.treesitter.navigate'.put_functions_in_list(false)<CR> 
nnoremap <silent> <Plug>(goldsmith-function-loclist-open) <cmd>lua require'goldsmith.treesitter.navigate'.put_functions_in_list(true)<CR> 

command! -nargs=+ -complete=custom,s:GoDocComplete GoDoc lua require('goldsmith.godoc').view(<f-args>)
command! -nargs=0 GoImports lua require'goldsmith.imports'.run_imports(1)
command! -nargs=0 GoFormat lua vim.lsp.buf.formatting_seq_sync()

lua require'goldsmith.config.treesitter-textobjects'.setup()

augroup goldsmith_ft_go
  autocmd! * <buffer>
  autocmd BufWritePre <buffer> lua require'goldsmith.imports'.run_imports(0)
  autocmd BufEnter    <buffer> lua require'goldsmith.buffer'.buffer_checkin()
augroup END

let &cpo = s:cpo_save
unlet s:cpo_save
