-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
local M = {
  ['0.6.11'] = {
    filetypes = { 'go', 'gomod' },
    cmd = {
      string.format("%s/lspinstall/go/gopls", vim.fn.stdpath('data')),
      '-remote=auto'
      -- debug:
      -- '-logfile=auto',
      -- '-rpc.trace'
    },
    settings = {
      gopls = {
        buildFlags = nil,
        env = nil,
        directoryFilters = nil,
        ["local"] = "",
        memoryMode = "Normal",
        gofumpt = true,
        usePlaceholders = true,
        semanticTokens = true,
        staticcheck = true,
        hoverKind = "Structured",
        annotations = {
          bounds = true,
          escape = true,
          inline = true,
          ["nil"] = true
        },
        experimentalPostfixCompletions = true,
        experimentalDiagnosticsDelay = "250ms",
        -- may also be "godoc.org"
        linkTarget = "pkg.go.dev",
        linksInHover = true,
        importShortcut = "Both",
        analyses = {
          asmdecl = true,
          assign = true,
          atomic = true,
          atomicalign = true,
          bools = true,
          buildtag = true,
          cgocall = true,
          composites = true,
          copylocks = true,
          deepequalerrors = true,
          errorsas = true,
          fieldalignment = true,
          fillreturns = true,
          fillstruct = true,
          httpresponse = true,
          ifaceassert = true,
          loopclosure = true,
          lostcancel = true,
          nilfunc = true,
          nilness = true,
          nonewvars = true,
          noresultvalues = true,
          printf = true,
          shadow = true,
          shift = true,
          simplifyrange = true,
          simplifyslice = true,
          sortslice = true,
          stdmethods = true,
          stringintconv = true,
          structtag = true,
          testinggoroutine = true,
          tests = true,
          undeclaredname = true,
          unmarshal = true,
          unreachable = true,
          unsafeptr = true,
          unusedparams = true,
          unusedresult = true,
          unusedwrite = true
        },
        codelenses = {
          gc_details = true,
          tidy = true,
          generate = false,
          regenerate_cgo = false,
          upgrade_dependency = false,
          vendor = false
        }
      }
    }
  }
}

return M
