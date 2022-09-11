" vint: -ProhibitAutocmdWithNoGroup

" apparently there are other filetypes that use *.mod, so get rid of them
autocmd! BufRead,BufNewFile *.mod,*.MOD
" for now assume any go.mod is the Go module file;
" nvim-treesitter also sets this filetype, but let's not depend on that
autocmd BufRead,BufNewFile go.mod set filetype=gomod

au BufRead,BufNewFile *.go setfiletype go
au BufRead,BufNewFile *.s setfiletype asm
au BufRead,BufNewFile *.tmpl set filetype=gohtmltmpl
au BufRead,BufNewFile go.sum set filetype=gosum
au BufRead,BufNewFile go.work.sum set filetype=gosum
au BufRead,BufNewFile go.work set filetype=gowork
