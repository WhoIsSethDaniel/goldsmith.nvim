let g:goldsmith_is_setup = v:false
if !has('nvim-0.8')
    echohl ErrorMsg
    echomsg 'Goldsmith requires at least neovim 0.8.0.'
    echomsg 'If you are using a version of Neovim that is at least 0.5.0, but not at least 0.8.0, please see'
    echomsg 'https://github.com/WhoIsSethDaniel/goldsmith.nvim/tree/prepare_for_0.8.0#keeping-up-to-date--releases'
    echohl None
    echoerr ''
    finish
endif

" do the actual configuring for LSP servers and other items that require a late setup/init
if !luaeval("require'goldsmith'.init()")
    finish
endif
let g:goldsmith_is_setup = v:true
