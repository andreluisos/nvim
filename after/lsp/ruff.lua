-- pyright provides hover; ruff's would duplicate it.
local function disable_hover(client)
  client.server_capabilities.hoverProvider = false
end

return {
  cmd_env = { RUFF_TRACE = "messages" },
  init_options = { settings = { logLevel = "error" } },
  on_attach = disable_hover,
}
