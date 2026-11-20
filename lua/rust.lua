local EXCLUDED_DIRECTORIES = {
  ".direnv",
  ".git",
  ".jj",
  ".github",
  ".gitlab",
  "bin",
  "node_modules",
  "target",
  "venv",
  ".venv",
}

vim.g.rustaceanvim = {
  server = {
    default_settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
          loadOutDirsFromCheck = true,
          buildScripts = { enable = true },
        },
        checkOnSave = true,
        diagnostics = { enable = true },
        procMacro = { enable = true },
        files = { exclude = EXCLUDED_DIRECTORIES, watcher = "client" },
      },
    },
  },
}
