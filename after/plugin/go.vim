let g:goldsmith_is_setup = v:false
if !has('nvim-0.5')
    echohl ErrorMsg
    echomsg 'Goldsmith requires at least neovim 0.5.0.'
    echohl None
    echoerr ''
    finish
endif

" do the actual configuring for LSP servers and other items that require a late setup/init
if !luaeval("require'goldsmith'.init()")
    finish
endif
let g:goldsmith_is_setup = v:true
