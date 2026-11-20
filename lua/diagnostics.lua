local quickfix = require("quickfix")
local CURRENT_BUFFER = 0
local BUFFER_LIST_TITLE = "Buffer diagnostics"

local function list_buffer_diagnostics()
  local items = vim.diagnostic.toqflist(vim.diagnostic.get(CURRENT_BUFFER))
  vim.fn.setqflist({}, " ", { title = BUFFER_LIST_TITLE, items = items })
  vim.cmd.copen()
end

local function toggle_diagnostics_list()
  if quickfix.is_open() then
    vim.cmd.cclose()
    return
  end
  list_buffer_diagnostics()
end

vim.keymap.set("n", "<leader>d", toggle_diagnostics_list, { silent = true, desc = "Toggle buffer diagnostics" })
