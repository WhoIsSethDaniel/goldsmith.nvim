" apparently there are other filetypes that use *.mod, so get rid of them
autocmd! BufRead,BufNewFile *.mod,*.MOD
" for now assume any go.mod is the Go module file;
" nvim-treesitter also sets this filetype, but let's not depend on that
autocmd BufRead,BufNewFile go.mod set filetype=gomod
