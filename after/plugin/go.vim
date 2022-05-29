let g:goldsmith_is_setup = v:false
if !has('nvim-0.7')
    echohl ErrorMsg
    echomsg 'Goldsmith requires at least neovim 0.7.0.'
    echomsg 'If you are using a version of Neovim that is at least 0.5 please see'
    echomsg 'https://github.com/WhoIsSethDaniel/goldsmith.nvim#releases--minimal-versions-of-dependencies'
    echohl None
    echoerr ''
    finish
endif

" do the actual configuring for LSP servers and other items that require a late setup/init
if !luaeval("require'goldsmith'.init()")
    finish
endif
let g:goldsmith_is_setup = v:true
