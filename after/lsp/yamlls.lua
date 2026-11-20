local function add_schemastore_schemas(_, config)
  config.settings.yaml.schemas =
    vim.tbl_deep_extend("force", config.settings.yaml.schemas or {}, require("schemastore").yaml.schemas())
end

return {
  capabilities = {
    textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } },
  },
  before_init = add_schemastore_schemas,
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      keyOrdering = false,
      format = { enable = true },
      validate = true,
      -- SchemaStore.nvim supplies the catalog, so the built-in download stays off.
      schemaStore = { enable = false, url = "" },
    },
  },
}
