-- vtsls carries the Angular TypeScript plugin and owns renames; two rename providers conflict.
local function disable_rename(client)
  client.server_capabilities.renameProvider = false
end

return { on_attach = disable_rename }
