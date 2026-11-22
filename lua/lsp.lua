local ENABLED_LANGUAGE_SERVERS = {
  "lua_ls",
  "vtsls",
  "vue_ls",
  "angularls",
  "tailwindcss",
  "jsonls",
  "yamlls",
  "taplo",
  "dockerls",
  "docker_compose_language_service",
  "pyright",
  "ruff",
  "kotlin_lsp",
  "clangd",
}
local INLAY_HINT_METHOD = "textDocument/inlayHint"
local INLAY_HINT_EXCLUDED_FILETYPES = { "vue" }
local TAILWIND_EXCLUDED_FILETYPES = { "markdown" }
local WORKSPACE_DIAGNOSTIC_METHOD = "workspace/diagnostic"
-- jdtls already publishes diagnostics for the whole project once its build finishes.
local WORKSPACE_DIAGNOSTICS_EXCLUDED_CLIENTS = { "jdtls" }

local workspace_diagnostics_requested = {}

local function enable_inlay_hints(client, bufnr)
  local is_excluded = vim.tbl_contains(INLAY_HINT_EXCLUDED_FILETYPES, vim.bo[bufnr].filetype)
  if client:supports_method(INLAY_HINT_METHOD) and not is_excluded then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

local function request_native_workspace_diagnostics(client)
  if workspace_diagnostics_requested[client.id] then
    return
  end
  workspace_diagnostics_requested[client.id] = true
  vim.lsp.buf.workspace_diagnostics({ client_id = client.id })
end

local function populate_workspace_diagnostics(client, bufnr)
  if vim.tbl_contains(WORKSPACE_DIAGNOSTICS_EXCLUDED_CLIENTS, client.name) then
    return
  end
  if client:supports_method(WORKSPACE_DIAGNOSTIC_METHOD, bufnr) then
    request_native_workspace_diagnostics(client)
    return
  end
  require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
end

local function configure_attached_buffer(event)
  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if not client then
    return
  end
  enable_inlay_hints(client, event.buf)
  populate_workspace_diagnostics(client, event.buf)
end

local function exclude_tailwind_filetypes()
  local filetypes = vim.tbl_filter(function(filetype)
    return not vim.tbl_contains(TAILWIND_EXCLUDED_FILETYPES, filetype)
  end, vim.lsp.config.tailwindcss.filetypes)
  vim.lsp.config("tailwindcss", { filetypes = filetypes })
end

vim.lsp.config("*", {
  capabilities = { workspace = { fileOperations = { didRename = true, willRename = true } } },
})
exclude_tailwind_filetypes()
vim.lsp.enable(ENABLED_LANGUAGE_SERVERS)

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  -- tiny-inline-diagnostic draws the messages; Neovim's virtual text would duplicate them.
  virtual_text = false,
  severity_sort = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
  desc = "Enable inlay hints and workspace diagnostics for attached language servers",
  callback = configure_attached_buffer,
})
