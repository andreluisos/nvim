local ENABLED_LANGUAGE_SERVERS = { "lua_ls", "tsgo" }
local COMPLETION_METHOD = "textDocument/completion"

local function enable_completion(event)
  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if client and client:supports_method(COMPLETION_METHOD) then
    vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
  end
end

vim.lsp.enable(ENABLED_LANGUAGE_SERVERS)
vim.diagnostic.config({ virtual_text = true })
vim.opt.completeopt:append("noselect")

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_completion", { clear = true }),
  desc = "Enable native LSP completion",
  callback = enable_completion,
})
