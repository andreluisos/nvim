local quickfix = require("quickfix")
local CURRENT_BUFFER = 0
local BUFFER_LIST_TITLE = "Buffer diagnostics"
local WORKSPACE_LIST_TITLE = "Workspace diagnostics"

local function show_diagnostics(diagnostics, title)
  vim.fn.setqflist({}, " ", { title = title, items = vim.diagnostic.toqflist(diagnostics) })
  vim.cmd.copen()
end

local function list_buffer_diagnostics()
  show_diagnostics(vim.diagnostic.get(CURRENT_BUFFER), BUFFER_LIST_TITLE)
end

local function list_workspace_diagnostics()
  show_diagnostics(vim.diagnostic.get(), WORKSPACE_LIST_TITLE)
end

local function build_toggle(list_diagnostics)
  return function()
    if quickfix.is_open() then
      vim.cmd.cclose()
      return
    end
    list_diagnostics()
  end
end

vim.keymap.set(
  "n",
  "<leader>d",
  build_toggle(list_buffer_diagnostics),
  { silent = true, desc = "Toggle buffer diagnostics" }
)
vim.keymap.set(
  "n",
  "<leader>D",
  build_toggle(list_workspace_diagnostics),
  { silent = true, desc = "Toggle workspace diagnostics" }
)
