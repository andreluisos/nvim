local CURRENT_BUFFER = 0
local STATE_MESSAGE_FORMAT = "%s %s"
local ENABLED_LABEL = "enabled"
local DISABLED_LABEL = "disabled"

local function notify_state(name, enabled)
  local label = enabled and ENABLED_LABEL or DISABLED_LABEL
  vim.notify(string.format(STATE_MESSAGE_FORMAT, name, label), vim.log.levels.INFO)
end

local function toggle_inlay_hints()
  local filter = { bufnr = CURRENT_BUFFER }
  local enabled = not vim.lsp.inlay_hint.is_enabled(filter)
  vim.lsp.inlay_hint.enable(enabled, filter)
  notify_state("Inlay hints", enabled)
end

local function toggle_wrap()
  vim.wo.wrap = not vim.wo.wrap
  notify_state("Wrap", vim.wo.wrap)
end

vim.keymap.set("n", "<leader>uh", toggle_inlay_hints, { desc = "Toggle inlay hints" })
vim.keymap.set("n", "<leader>uw", toggle_wrap, { desc = "Toggle wrap" })
