# Goldsmith
Go development environment for Neovim utilizing the builtin LSP and other features and plugins specific to Neovim.

# Features
view all screencasts [here](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-1)

* codelens support [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-1#codelens-support)
* inlay hints support [screenshots](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-6#inlay-hints) - *you need to have gopls 0.9.0 or greater for this to work*
* flag and update out-of-date dependencies in your current Go module [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-1#go-module-check-for-updates)
* automatically run goimports on save [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-1#run-goimports-on-save)
* auto-highlight the current symbol under the cursor throughout the current buffer [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-2#symbol-highlighting)
* treesitter navigation utilizing the nvim-treesitter-textobjects plugin
* treesitter text objects utilizing the nvim-treesitter-textobjects plugin
* convert JSON to Go structs directly in your code, or paste from outside the editor [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-5#convert-json-to-go-struct)
* view Go documentation using the :GoDoc command and Go help with :GoHelp [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-2#documentation-and-help)
* context sensitive help with either :GoContextHelp or via a keybinding
* manually update imports using the :GoImports command [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-2#manual-goimports-support)
* use :checkhealth to see if your Goldsmith setup should work correctly [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-3#use-checkhealth-to-check-goldsmith-setup)
* format your code on demand using :GoFormat or have Goldsmith automatically format your code on save [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-3#manual-formatting-using-goformat)
* integration with [Telescope](https://github.com/nvim-telescope/telescope.nvim) for a number of file picking needs [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-6#telescope-integration)
* run extra linters and/or formatters using null-ls: currently has support for golines, gofmt, gofumpt, revive, golangci-lint, and staticcheck
* see the source of the diagnostic when running extra linters
* Goldsmith can completely configure everything for you, if you want (see the [Configurations](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Configurations) wiki for more)
* generate test stubs automatically using `gotests` [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-3#switch-to-alternate-file--generate-stub-tests)
* create implementation stubs for your interfaces using :GoImpl [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-4#create-interface-implementation-stubs)
* :GoFillStruct utilizes LSP to fill the current struct
* switch to the 'alternate' file quickly [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-3#switch-to-alternate-file--generate-stub-tests)
* struct tag editing: add / remove / update struct tags and options [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-4#struct-tag-editing)
* use common go subcommands from within Neovim with: :GoBuild, :GoInstall, :GoGet, :GoRun, and others [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-4#using-gobuild-and-gorun)
* coverage support: annotate the current buffer and store coverage data for all files affected [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-5#coverage-report)
* statusline integration: see the status of running jobs and of coverage data for the current buffer [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-5#statusline-integration)
* edit the go.mod file from within Neovim with: :GoModTidy, :GoModCheck, :GoModRetract, :GoModReplace, and others
* use the excellent builtin testing framework to run individual tests, package tests, or all your tests
* all the great Neovim LSP functions are available as Vim commands
* most commands are completely asynchronous
* support for  [nvim-lsp-installer](https://github.com/williamboman/nvim-lsp-installer)

# Releases / Minimal Versions of Dependencies

The _main_ branch of Goldsmith should always work with the most recent stable version of Neovim. It may also work with
nightly Neovim (with some delay). If you are always running nightly or always have the most recent stable version then
you will probably want to use _main_ at all times.

`go` versions should be either the most recent minor version or within one minor version of the most recent. So if the
most recent `go` version is 1.18.3 this means Goldsmith should work with at least 1.17.0 and newer.

`nvim-lspconfig` should always be at or near the latest. A good faith effort will be made to help transition to versions
of `nvim-lspconfig` that have major breakage, but cannot be guaranteed. Please [ask a question](https://github.com/WhoIsSethDaniel/goldsmith.nvim/discussions) 
or [report a problem](https://github.com/WhoIsSethDaniel/goldsmith.nvim/issues) if you think that we can do a better
job or if you are having a problem.

`gopls` should always be very recent if you wish to follow the _main_ branch. It does not necessarily need to be the
most recent but should be within one minor version of the most recent.

Other dependencies, such as `null-ls` or `nvim-lsp-installer`, will be handled as problems occur (which is rare).

Starting with `Neovim 0.6.1`, for every new minor version of Neovim (i.e. 0.5, 0.6, 0.7, etc...), there will be a branch
and a tag. The branch and tag are created _after_ an even newer minor version of Neovim is available, and are made
available for those who cannot afford to stay at the leading edge. If you checkout the tag or the branch you will get
the lastest version of Goldsmith for that minor version of Neovim. e.g. if you are using Neovim 0.X.Y you would want to
checkout the `nvim-0.X` tag and/or the `stable-nvim-0.X` branch. The only exception to this rule is anything `0.6.1` or
earlier (back to `0.5.0`). For those versions you will want to checkout either the `nvim-0.6` tag or the
`stable-nvim-0.6` branch. It cannot be guaranteed that the branch and/or tag will work with the lastest version of 
various other dependencies (such as nvim-lspconfig, treesitter, null-ls, etc...).

Goldsmith *will not work* with Vim or versions of Neovim prior to 0.5.0.

Run `:checkhealth goldsmith` after installing to see what is required and what needs to be done to meet the minimal 
requirements.

If you discover that any of the above is *not* the case, or you find it confusing, please consider [asking a
question](https://github.com/WhoIsSethDaniel/goldsmith.nvim/discussions) or [reporting a
problem](https://github.com/WhoIsSethDaniel/goldsmith.nvim/issues).

# Installation
Install using your favorite plugin manager. 

If you use vim-plug:
```vim
Plug 'WhoIsSethDaniel/goldsmith.nvim'
```
Or if you use Vim 8 style packages:
```bash
cd <plugin dir>
git clone https://github.com/WhoIsSethDaniel/goldsmith.nvim
```

# Quickstart
1. Install [Go](https://golang.org/dl/).
1. Install Goldsmith, [lspconfig](https://github.com/neovim/nvim-lspconfig), [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) and [null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim).
1. Install required external programs: 
    ```bash
    nvim +GoInstallBinaries
    ```
    You may receive some warnings from Goldsmith about missing programs. These can be ignored since you are now installing those programs.

    After the installation completes (usually within a minute or so) run 
    ```vim
    :checkhealth goldsmith
    ```
    Make certain everything looks okay.
1. Restart Neovim.  
1. Start editing Go code.
1. Currently you are running with Goldsmith defaults. So take a look at the documentation and tweak your configuration.

# Configuration
See the [configuration page](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Configurations) on the wiki for examples demonstrating how
to configure Goldsmith.

Also see the Goldsmith [:help documentation](https://github.com/WhoIsSethDaniel/goldsmith.nvim/blob/main/doc/goldsmith.txt) or 
after installing Goldsmith by using `:h goldsmith`.

# Reporting Problems / Asking Questions
Goldsmith is very new. It works for the author, but does it work for you? If not, please consider [asking a 
question](https://github.com/WhoIsSethDaniel/goldsmith.nvim/discussions) or [reporting a
problem](https://github.com/WhoIsSethDaniel/goldsmith.nvim/issues).
