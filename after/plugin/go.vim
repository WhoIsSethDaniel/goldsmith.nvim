if !has('nvim-0.5')
    call nvim_echo([['goldsmith requires at least neovim 0.5.0.', 'ErrorMsg']], v:true, {})
    finish
endif

" do the actual configuring for LSP servers and other items that require a late setup/init
lua require'goldsmith'.init()
