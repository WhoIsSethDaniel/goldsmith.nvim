# Goldsmith
Go development environment for Neovim utilizing the builtin LSP and other features and plugins specific to Neovim.

# Features
view all screencasts [here](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-1)

* codelens support [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-1#codelens-support)
* flag and update out-of-date dependencies in your current Go module [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-1#go-module-check-for-updates)
* automatically run goimports on save [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-1#run-goimports-on-save)
* auto-highlight the current symbol under the cursor throughout the current buffer [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-2#symbol-highlighting)
* treesitter navigation utilizing the nvim-treesitter-textobjects plugin
* treesitter text objects utilizing the nvim-treesitter-textobjects plugin
* view Go documentation using the :GoDoc command and Go help with :GoHelp [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-2#documentation-and-help)
* manually update imports using the :GoImports command [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-2#manual-goimports-support)
* use :checkhealth to see if your Goldsmith setup should work correctly [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-3#use-checkhealth-to-check-goldsmith-setup)
* format your code on demand using :GoFormat or have Goldsmith automatically format your code on save [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-3#manual-formatting-using-goformat)
* run extra linters and/or formatters using null-ls: currently has support for golines, revive, golangci-lint, and staticcheck
* see the source of the diagnostic when running extra linters
* Goldsmith can completely configure everything for you, if you want (see the [Configurations](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Configurations) wiki for more)
* generate test stubs automatically using `gotests` [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-3#switch-to-alternate-file--generate-stub-tests)
* create implementation stubs for your interfaces using :GoImpl [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-4#create-interface-implementation-stubs)
* :GoFillStruct utilizes LSP to fill the current struct
* commands for common tasks (the following list is not complete):
    * switch to the 'alternate' file quickly [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-3#switch-to-alternate-file--generate-stub-tests)
    * struct tag editing: add / remove / update struct tags and options [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-4#struct-tag-editing)
    * build your project using :GoBuild 
    * run your main package using :GoRun
    * fetch new Go libraries using :GoGet
    * install new Go tools using :GoInstall
    * run tests using :GoTest
* all the great Neovim LSP functions are available as Vim commands
* most commands are completely asynchronous

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

# Configuration
See the [configuration page](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Configurations) on the wiki for examples demonstrating how
to configure Goldsmith.

Also see the Goldsmith [:help documentation](https://github.com/WhoIsSethDaniel/goldsmith.nvim/blob/main/doc/goldsmith.txt) or 
after installing Goldsmith by using `:h goldsmith`.

The most basic configuration is:
```lua
require("goldsmith").config()
```
However, if you already have lspconfig configured you may want to do this:
```lua
require("goldsmith").config({ autoconfig = false })
```
There are many other options. See the [configuration page](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Configurations) on the wiki and
the Goldsmith [:help documentation](https://github.com/WhoIsSethDaniel/goldsmith.nvim/blob/main/doc/goldsmith.txt) for much more information.

# Minimal Requirements
* Neovim >= 0.5.0
* go >= 1.14
* gopls >= 0.6.6[\*] 
* [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

These 'minimal' requirements are not hard-and-fast. They are simply the minimal versions that the author has been able
to test with. Goldsmith may work just fine with older versions of Go, gopls, etc.... Neovim, however, must be at least
0.5.0 and nvim-lspconfig is also a hard requirement.

*Goldsmith will not work with Vim or versions of Neovim prior to 0.5.0.*

Run `:checkhealth goldsmith` after installing to see what is required and what needs to be done to meet the minimal 
requirements.

[\*] *Goldsmith depends on package completion provided by gopls. Prior to 0.6.6 this did not exist. If you use a gopls
earlier than 0.6.6 it means package completion will not work for those commands that require it.

# Reporting Problems / Asking Questions
Goldsmith is very new. It works for the author, but does it work for you? If not, please consider [asking a 
question](https://github.com/WhoIsSethDaniel/goldsmith.nvim/discussions) or [reporting a
problem](https://github.com/WhoIsSethDaniel/goldsmith.nvim/issues).
