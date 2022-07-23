if exists('b:did_ftplugin')
    finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

if g:goldsmith_is_setup == v:false
    echohl ErrorMsg
    echomsg 'Goldsmith: Cannot setup current buffer. Goldsmith failed to initialize.'
    echohl None
    echoerr ''
    finish
endif

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
command! -nargs=0 GoContextHelp lua require'goldsmith.cmds.contextualhelp'.run()
command! -nargs=+ -complete=custom,s:GoDocComplete GoDoc lua require'goldsmith.cmds.doc'.run('doc', {<f-args>})
command! -nargs=1 -complete=custom,s:GoHelpComplete GoHelp lua require'goldsmith.cmds.doc'.run('help', {<f-args>})
command! -nargs=* -bang -complete=custom,v:lua.goldsmith_package_complete GoBuild lua require'goldsmith.cmds.build'.run('<bang>', {<f-args>})
command! -nargs=* -bang -complete=custom,v:lua.goldsmith_package_complete GoRun lua require'goldsmith.cmds.run'.run('<bang>', {<f-args>})
command! -nargs=* GoBuildLast lua require'goldsmith.cmds.build'.last({<f-args>})
command! -nargs=* GoRunLast lua require'goldsmith.cmds.run'.last({<f-args>})
command! -nargs=* GoGet lua require'goldsmith.cmds.get'.run({<f-args>})
command! -nargs=* GoInstall lua require'goldsmith.cmds.install'.run({<f-args>})
command! -nargs=0 -bang GoAlt lua require'goldsmith.cmds.alt'.run('<bang>')

" formatting
command! -nargs=0 GoImports lua require'goldsmith.cmds.format'.organize_imports()
command! -nargs=0 GoFormat lua require'goldsmith.cmds.format'.run(true)

" creating/editing tests
lua require'goldsmith.testing'.setup()
command! -nargs=* -bang -complete=custom,v:lua.goldsmith_package_complete GoTest lua require'goldsmith.cmds.test'.run('<bang>', {<f-args>})
command! -nargs=? GoAddTests lua require'goldsmith.cmds.tests'.generate({<f-args>})
command! -nargs=* -complete=custom,s:GoAddTestComplete GoAddTest lua require'goldsmith.cmds.tests'.add({<f-args>})

" coverage
command! -nargs=* -bang -complete=custom,v:lua.goldsmith_package_complete GoCoverage lua require'goldsmith.cmds.coverage'.run({bang='<bang>',type='job'}, {<f-args>})
command! -nargs=* -bang -complete=custom,v:lua.goldsmith_package_complete GoCoverageBrowser lua require'goldsmith.cmds.coverage'.run({bang='<bang>',type='web'}, {<f-args>})
command! -nargs=0 GoCoverageFiles lua require'goldsmith.cmds.coverage'.show_files()
command! -nargs=0 GoCoverageOn lua require'goldsmith.cmds.coverage'.on()
command! -nargs=0 GoCoverageOff lua require'goldsmith.cmds.coverage'.off()

" code editing
command! -nargs=* -range GoAddTags lua require'goldsmith.cmds.tags'.run('add', {line1=<line1>, line2=<line2>, count=<count>}, {<f-args>})
command! -nargs=* -range GoRemoveTags lua require'goldsmith.cmds.tags'.run('remove', {line1=<line1>, line2=<line2>, count=<count>}, {<f-args>})
command! -nargs=* -range GoClearTags lua require'goldsmith.cmds.tags'.run('remove', {line1=<line1>, line2=<line2>, count=<count>}, {})
command! -nargs=* -complete=custom,s:GoImplComplete GoImpl lua require'goldsmith.cmds.impl'.run({<f-args>})
command! -nargs=0 GoFillStruct lua require'goldsmith.cmds.fillstruct'.run(1000)
command! -nargs=0 GoComments lua require'goldsmith.cmds.comment'.run()
command! -nargs=? -range GoToStruct lua require'goldsmith.cmds.tostruct'.run({line1=<line1>, line2=<line2>, count=<count>, type='paste'}, {<f-args>})
command! -nargs=? -range GoToStructReg lua require'goldsmith.cmds.tostruct'.run({line1=<line1>, line2=<line2>, count=<count>, type='register'}, {<f-args>})

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

" inlay hints
command! -nargs=0 GoInlayHintsOn lua require'goldsmith.cmds.inlay_hints'.turn_on_inlay_hints()
command! -nargs=0 GoInlayHintsOff lua require'goldsmith.cmds.inlay_hints'.turn_off_inlay_hints()

" initial setup
command! -nargs=* -bang -complete=custom,s:GoCreateConfigsComplete GoCreateConfigs lua require'goldsmith.cmds.setup'.create_configs('<bang>',{<f-args>})

" debug
command! -nargs=0 GoDebugConsole lua require'goldsmith.cmds.debug'.run()

augroup goldsmith_ft_go
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> lua require'goldsmith.cmds.format'.run(false)
    autocmd BufEnter,CursorHold,CursorHoldI <buffer> lua require'goldsmith.codelens'.maybe_run()
    autocmd BufEnter,CursorHold,CursorHoldI <buffer> lua require'goldsmith.highlight'.maybe_run()
    autocmd BufEnter,CursorHold,CursorHoldI <buffer> lua require'goldsmith.inlay_hints'.maybe_run()
augroup END

lua require'goldsmith.buffer'.setup()

let &cpo = s:cpo_save
unlet s:cpo_save
