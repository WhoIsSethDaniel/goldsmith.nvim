# Goldsmith

Go development environment for Neovim utilizing the builtin LSP and other features and plugins specific to Neovim.

## Features / TODO
- [x] goimports
    - [x] run automatically upon save with gopls
- [x] treesitter navigation - uses [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)
    - [x] jump to next/previous function/method
- [x] treesitter text objects - uses [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)
    - [x] function (af/if)
    - [x] comment (ac)
- [x] GoDoc - for viewing installed documentation
    - [x] package name completion
    - [ ] floating window support
    - [ ] keyword support (a better 'K'?)
    - [ ] retrieve documentation for individual functions/methods
- [x] GoImports - manually run goimports (via gopls)
- [x] GoBuild  - go build
- [x] GoRun - go run
- [x] GoFormat - manually run formatter(s)
- [x] GoGet - run go get
- [x] GoInstall - run go install
- [ ] GoLint - for manually running linters (via efm)
- [x] GoInstallBinaries - install all needed 3rd-party tools
- [x] plugin documentation
    - [x] vim doc
    - [x] list of all needed/supported [n]vim plugins
- [ ] testing support
    - [x] GoTest 
    - [ ] GoTestFunc 
    - [ ] make above wrappers around vim-test? or vim-ultest? both?
    - [ ] use `gotests` to generate skeleton testing file
- [x] structs
    - [x] field tag editing (gomodifytags) - asynchronous
- [x] checkhealth
- [ ] functions provided for many actions
- [ ] LSP related
    - [ ] code actions require prompt when only 1 action. add config to fix this.
    - [ ] show source of warning in vtext
    - [ ] statusline diags
- [ ] LSP config related
    - [ ] auto config of gopls
    - [ ] auto config of efm
    - [ ] linting / formatting
        - [ ] provide efm configs for
            - [ ] golines
            - [ ] revive
            - [ ] other linters / formatters not supported by gopls?
        - [ ] provide better / different gopls configuration/s w/ lspconfig
- [ ] go.mod 
    - [ ] editing (such as replace etc...)
    - [ ] tidy
    - [ ] downloading
- [ ] interesting tools
    - [ ] fillswitch
    - [ ] fixplurals
- [ ] go specific rules for nvim-autopairs? or similar
- [ ] generate skeleton code documentation / comments (gocmt - https://github.com/cuonglm/gocmt)
- [ ] workspaces / multiple workspaces
- [ ] build tag editing
- [ ] perhaps go.work support (https://github.com/golang/go/issues/45713)

## Details
Written in Lua so it only works with NeoVim. This is meant to be both useful (to me, at least) and to work as a testbed
for working with Lua in NeoVim. This is the first thing I have ever written using Lua. I have written a fair amount of
VimScript, but have never made a dedicated package I wished to share.

## Documentation
Please see the documentation [here](https://github.com/WhoIsSethDaniel/goldsmith.nvim/blob/main/doc/goldsmith.txt) for much more information.

## Similar Projects
* [go.nvim](https://github.com/ray-x/go.nvim)
* [nvim-go](https://github.com/crispgm/nvim-go)
