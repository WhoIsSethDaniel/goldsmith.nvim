# Goldsmith

Go development environment for Neovim utilizing the builtin LSP and other features and plugins specific to Neovim.

## Features
* :GoDoc command (see below)
    * package name completion
* auto-run goimports upon save via gopls
* navigation
    * jump to next/previous function/method. Utilizes treesitter.
    * place all functions/method in the location list and use it for navigation. Utilizes treesitter.

## Commands
To view documentation in a window use GoDoc:
```vim
:GoDoc [opts] <doc> 
```
e.g. 
```vim
view documentation for the 'fmt' package
:GoDoc fmt

use any option you can pass to 'go doc'
view all documentation for the 'fmt' package
:GoDoc -all fmt

view the source code for the 'fmt' package
:GoDoc -src fmt
```
You can use tab completion when typing the name of the package to view documentation for. e.g.:
```
:GoDoc <tab>
```
will show all available packages, and
```
:GoDoc f<tab>
```
will show all available packages that begin with the letter 'f'.

## Mappings

### Navigation
You can map jumping to the next/previous function/method. The following maps ]] to jump to the
next function/method and [[ to jump to the previous function/method:
```lua
vim.api.nvim_set_keymap('n', ']]', '<Plug>(goldsmith-next-function)', { silent = true })
vim.api.nvim_set_keymap('n', '[[', '<Plug>(goldsmith-prev-function)', { silent = true })
```
You can also navigate from function to function (or method) using the location list:
```lua
vim.api.nvim_set_keymap('n', '<leader>fl', '<Plug>(goldsmith-func-loclist)', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>flo', '<Plug>(goldsmith-func-loclist-open)', { silent = true })
```
For goldsmith-func-loclist you will need to open the location list afterwards.  For goldsmith-func-loclist-open
the location list will automatically open if there are any entries in the list.

## Configuration
By default help pages are open in a horizontal window. One way to change this is to set
```vim
let g:goldsmith_open_split = 'vertical'
```
This will open help pages in a vertical window.

## Details
Written in Lua so it only works with NeoVim. This is meant to be both useful (to me, at least) and to work as a testbed
for working with Lua in NeoVim. This is the first thing I have ever written using Lua. I have written a fair amount of
VimScript, but have never made a dedicated package I wished to share.

## TODO
* documentation
    * floating window support
    * keyword support
    * retrieve documentation for individual functions/methods
    * vendor dir support for completion
    * LSP support
* linting / formatting
    * provide efm configs for
        * golines
        * other linters / formatters not supported by gopls?
    * provide better / different gopls configuration/s w/ lspconfig
* lsp command support?
    * https://github.com/golang/tools/blob/master/gopls/doc/commands.md
    * https://microsoft.github.io/language-server-protocol/specifications/specification-current/#workspace_executeCommand 
    * vim.lsp.buf.execute_command() maybe?
* treesitter text objects?
* go.mod editing
* perhaps go.work support (https://github.com/golang/go/issues/45713)
* many other things

## Similar Projects
* [go.nvim](https://github.com/ray-x/go.nvim)
* [nvim-go](https://github.com/crispgm/nvim-go)
