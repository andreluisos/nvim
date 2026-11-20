local function add_schemastore_schemas(_, config)
  config.settings.json.schemas = config.settings.json.schemas or {}
  vim.list_extend(config.settings.json.schemas, require("schemastore").json.schemas())
end

return {
  before_init = add_schemastore_schemas,
  settings = {
    json = {
      format = { enable = true },
      validate = { enable = true },
    },
  },
}
