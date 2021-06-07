# Goldsmith

Go development environment for Neovim utilizing the builtin LSP and other features and plugins specific to Neovim.

## Features
* :GoDoc command (see below)
* auto-run goimports upon save via gopls
* navigation
    * jump to next/previous function/method. Utilizes treesitter.
    * place all functions/method in the location list and use it for navigation. Utilizes treesitter.
* diagnostic toggling
    * turn all diagnostics on/off
    * toggle underline, signs, virtual text, update in insert on/off individually

## Commands
To view documentation in a window use GoDoc:
```
:GoDoc [opts] <doc> 
```
e.g. 
```
view documentation for the 'fmt' package
:GoDoc fmt

use any option you can pass to 'go doc'
view all documentation for the 'fmt' package
:GoDoc -all fmt

view the source code for the 'fmt' package
:GoDoc -src fmt
```

## Mappings

### Navigation
You can map jumping to the next/previous function/method. The following maps ]] to jump to the
next function/method and [[ to jump to the previous function/method:
```
vim.api.nvim_set_keymap('n', ']]', '<Plug>(goldsmith-next-function)', { silent = true })
vim.api.nvim_set_keymap('n', '[[', '<Plug>(goldsmith-prev-function)', { silent = true })
```
You can also navigate from function to function (or method) using the location list:
```
vim.api.nvim_set_keymap('n', '<leader>fl', '<Plug>(goldsmith-func-loclist)', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>flo', '<Plug>(goldsmith-func-loclist-open)', { silent = true })
```
For goldsmith-func-loclist you will need to open the location list afterwards.  For goldsmith-func-loclist-open
the location list will automatically open if there are any entries in the list.

### Diagnostics
You can turn ALL diagnostics on or off with a simple set of keymappings. e.g.:
```
vim.api.nvim_set_keymap('n', '<leader>do', '<Plug>(goldsmith-diag-on)', {})
vim.api.nvim_set_keymap('n', '<leader>df', '<Plug>(goldsmith-diag-off)', {})
```
Toggle various individual features of diagnostics on/off. Toggle undelining, symbols in the signs column,
virtual text, and updating diagnostics while in insert mode.
```
vim.api.nvim_set_keymap('n', '<leader>tdu', '<Plug>(goldsmith-toggle-diag-underline)', {})
vim.api.nvim_set_keymap('n', '<leader>tds', '<Plug>(goldsmith-toggle-diag-signs)', {})
vim.api.nvim_set_keymap('n', '<leader>tdv', '<Plug>(goldsmith-toggle-diag-vtext)', {})
vim.api.nvim_set_keymap('n', '<leader>tdi', '<Plug>(goldsmith-toggle-diag-update_in_insert)', {})
```
These mappings will turn on/off the various diagnostics for all buffers and all clients.

## Configuration
By default help pages are open in a horizontal window. One way to change this is to set
```
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
        * revive
        * other linters / formatters not supported by gopls
* go.mod editing
* many other things
