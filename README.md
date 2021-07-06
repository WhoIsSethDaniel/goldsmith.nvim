# Goldsmith

Go development environment for Neovim utilizing the builtin LSP and other features and plugins specific to Neovim.

## Features / TODO
- [X] goimports
    - [X] run automatically upon save with gopls
    - [ ] GoImport - manually run goimports
    - [ ] provide efm as alternate to gopls
- [X] navigation
    - [X] jump to next/previous function/method. Utilizes treesitter.
    - [X] place all functions/method in the location list and use it for navigation. Utilizes treesitter.
- [X] GoDoc - for viewing installed documentation
    - [X] package name completion
    - [ ] floating window support
    - [ ] keyword support (a better 'K')
    - [ ] retrieve documentation for individual functions/methods
- [ ] GoBuild / GoRun - build / run packages
- [ ] GoGet - run go get
- [ ] GoInstall - run go install
- [ ] GoLint - for manually running linters (via efm)
- [ ] GoInstallBinaries - install all needed 3rd-party tools
- [ ] testing support
    - [ ] GoTest - wrappers around vim-test? or vim-ultest?
    - [ ] use `gotests` to generate skeleton testing file
- [ ] build tag editing
- [ ] structs
    - [ ] field tag editing (gomodifytags)
    - [ ] field filling (see fillstruct)
    - [ ] other tools (maybe un-needed due to gopls?)
        - [ ] keyify (turns un-keyed struct literals to keyed struct literals)
        - [ ] fillstruct (fills a struct with defaults (zero values))
- [ ] generate code documentation
- [ ] documentation
    - [ ] vim doc
    - [ ] list of all needed/supported [n]vim plugins
- [ ] LSP config related
    - [ ] auto config of efm and gopls
    - [ ] linting / formatting
        - [ ] provide efm configs for
            - [ ] golines
            - [ ] other linters / formatters not supported by gopls?
        - [ ] provide better / different gopls configuration/s w/ lspconfig
- [ ] treesitter text objects
- [ ] go.mod 
    - [ ] editing (such as replace etc...)
    - [ ] tidy
    - [ ] downloading
- [ ] perhaps go.work support (https://github.com/golang/go/issues/45713)

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

## Similar Projects
* [go.nvim](https://github.com/ray-x/go.nvim)
* [nvim-go](https://github.com/crispgm/nvim-go)
