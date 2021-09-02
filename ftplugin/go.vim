if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

compiler go

setlocal textwidth=0
setlocal noexpandtab
setlocal formatoptions-=t
setlocal comments=s1:/*,mb:*,ex:*/,://
setlocal commentstring=//\ %s

function s:GoDocComplete(A,C,P) abort
	return luaeval("require'goldsmith.cmds.doc'.doc_complete(_A[1], _A[2], _A[3])", [a:A, a:C, a:P])
endfunction

function s:GoHelpComplete(A,C,P) abort
	return luaeval("require'goldsmith.cmds.doc'.help_complete(_A[1], _A[2], _A[3])", [a:A, a:C, a:P])
endfunction

function s:GoAddTestComplete(A,C,P) abort
	return luaeval("require'goldsmith.cmds.tests'.complete(_A[1], _A[2], _A[3])", [a:A, a:C, a:P])
endfunction

function s:GoImplComplete(A,C,P) abort
	return luaeval("require'goldsmith.cmds.impl'.complete(_A[1], _A[2], _A[3])", [a:A, a:C, a:P])
endfunction

function s:GoCreateConfigsComplete(A,C,P) abort
	return luaeval("require'goldsmith.cmds.setup'.complete(_A[1], _A[2], _A[3])", [a:A, a:C, a:P])
endfunction

" terminal/window commands
command! -nargs=+ -complete=custom,s:GoDocComplete GoDoc lua require'goldsmith.cmds.doc'.run('doc', {<f-args>})
command! -nargs=1 -complete=custom,s:GoHelpComplete GoHelp lua require'goldsmith.cmds.doc'.run('help', {<f-args>})
command! -nargs=* GoBuild lua require'goldsmith.cmds.build'.run({<f-args>})
command! -nargs=* GoRun lua require'goldsmith.cmds.run'.run({<f-args>})
command! -nargs=* GoGet lua require'goldsmith.cmds.get'.run({<f-args>})
command! -nargs=* GoInstall lua require'goldsmith.cmds.install'.run({<f-args>})
command! -nargs=0 -bang GoAlt lua require'goldsmith.cmds.alt'.run('<bang>')
if luaeval("require'goldsmith.config'.get('goalt', 'shortcut')")
command! -nargs=0 -bang A lua require'goldsmith.cmds.alt'.run('<bang>')
endif

command! -nargs=0 GoImports lua require'goldsmith.cmds.format'.run_goimports(1)
command! -nargs=0 GoFormat lua require'goldsmith.cmds.format'.run(1)

" creating/editing tests
lua require'goldsmith.testing'.setup()
command! -nargs=* -bar -bang GoTest lua require'goldsmith.cmds.test'.run('<bang>', {<f-args>})
command! -nargs=? GoAddTests lua require'goldsmith.cmds.tests'.generate({<f-args>})
command! -nargs=* -complete=custom,s:GoAddTestComplete GoAddTest lua require'goldsmith.cmds.tests'.add({<f-args>})

" code editing
command! -nargs=* -range GoAddTags lua require'goldsmith.cmds.tags'.run('add', {line1=<line1>, line2=<line2>, count=<count>}, {<f-args>})
command! -nargs=* -range GoRemoveTags lua require'goldsmith.cmds.tags'.run('remove', {line1=<line1>, line2=<line2>, count=<count>}, {<f-args>})
command! -nargs=* -range GoClearTags lua require'goldsmith.cmds.tags'.run('remove', {line1=<line1>, line2=<line2>, count=<count>}, {})
command! -nargs=* -complete=custom,s:GoImplComplete GoImpl lua require'goldsmith.cmds.impl'.run({<f-args>})
command! -nargs=0 GoFillStruct lua require'goldsmith.cmds.fillstruct'.run(1000)

" navigation
command! -nargs=0 GoDef lua require'goldsmith.cmds.lsp'.goto_definition()
command! -nargs=0 GoInfo  lua require'goldsmith.cmds.lsp'.hover()
command! -nargs=0 GoSigHelp lua require'goldsmith.cmds.lsp'.signature_help()
command! -nargs=0 GoDefType lua require'goldsmith.cmds.lsp'.type_definition()
cabbrev GoTypeDef GoDefType
command! -nargs=0 GoCodeAction lua require'goldsmith.cmds.lsp'.code_action()
command! -nargs=0 GoRef lua require'goldsmith.cmds.lsp'.references()
command! -nargs=0 GoShowDiag lua require'goldsmith.cmds.lsp'.show_diagnostics()
command! -nargs=0 GoListDiag lua require'goldsmith.cmds.lsp'.diag_set_loclist()
command! -nargs=1 GoRename lua require'goldsmith.cmds.lsp'.rename({<f-args>})

" highlighting
command! -nargs=0 GoSymHighlight lua require'goldsmith.cmds.lsp'.highlight_current_symbol()
command! -nargs=0 GoSymHighlightOn lua require'goldsmith.cmds.lsp'.turn_on_symbol_highlighting()
command! -nargs=0 GoSymHighlightOff lua require'goldsmith.cmds.lsp'.turn_off_symbol_highlighting()

" codelens
command! -nargs=0 GoCodeLensRun lua require'goldsmith.cmds.lsp'.run_codelens()
command! -nargs=0 GoCodeLensOn lua require'goldsmith.cmds.lsp'.turn_on_codelens()
command! -nargs=0 GoCodeLensOff lua require'goldsmith.cmds.lsp'.turn_off_codelens()

" initial setup
command! -nargs=* -bang -complete=custom,s:GoCreateConfigsComplete GoCreateConfigs lua require'goldsmith.cmds.setup'.create_configs('<bang>',{<f-args>})

" debug
command! -nargs=0 GoDebugConsole lua require'goldsmith.cmds.debug'.run()

augroup goldsmith_ft_go
  autocmd! * <buffer>
  autocmd BufWritePre,InsertLeave <buffer> lua require'goldsmith.cmds.format'.run(0)
  autocmd CursorHold,CursorHoldI <buffer> lua require'goldsmith.highlight'.current_symbol()
  autocmd CursorHold,InsertLeave <buffer> lua require'goldsmith.codelens'.update()
augroup END

lua require'goldsmith.buffer'.checkin()
lua require'goldsmith.buffer'.set_buffer_options()

let &cpo = s:cpo_save
unlet s:cpo_save
