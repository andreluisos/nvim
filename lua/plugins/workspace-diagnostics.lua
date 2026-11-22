local workspace_diagnostics_server_names = { "vtsls", "pyright", "clangd", "vue_ls", "angularls" }

local function populate_workspace_diagnostics_for_listed_servers(buffer, client)
  if vim.tbl_contains(workspace_diagnostics_server_names, client.name) then
    require("workspace-diagnostics").populate_workspace_diagnostics(client, buffer)
  end
end

return {
  "artemave/workspace-diagnostics.nvim",
  enabled = true,
  event = "LspAttach",
  config = function()
    Snacks.util.lsp.on(populate_workspace_diagnostics_for_listed_servers)
  end,
}
