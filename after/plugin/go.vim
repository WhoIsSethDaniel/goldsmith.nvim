let g:goldsmith_is_setup = v:false
let g:goldsmith_config_ok = v:false
if !has('nvim-0.8')
    echohl ErrorMsg
    echomsg 'Goldsmith requires at least neovim 0.8.0.'
    echomsg 'If you are using a version of Neovim that is at least 0.5.0, but not at least 0.8.0, please see'
    echomsg 'https://github.com/WhoIsSethDaniel/goldsmith.nvim/tree/prepare_for_0.8.0#keeping-up-to-date--releases'
    echohl None
    echoerr ''
    finish
endif

" check the configuration early
if !luaeval("require'goldsmith'.pre()")
    finish
endif
let g:goldsmith_config_ok = v:true
