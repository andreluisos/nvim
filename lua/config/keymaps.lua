-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("n", "<leader>fC", function()
  -- %:p is the Neovim command-line modifier to get the full absolute path of the current file.
  local absolute_path = vim.fn.expand("%:p")

  -- vim.fn.setreg('+') sets the contents of the system clipboard (+)
  vim.fn.setreg("+", absolute_path)

  -- Provide a notification to the user that the operation was successful
  vim.notify("Copied absolute path to clipboard: " .. absolute_path, vim.log.levels.INFO, {
    title = "File Path Copied",
  })
end, {
  noremap = true,
  silent = true,
  desc = "Copy absolute file path to clipboard",
})

-- [[ DAP ]]
vim.keymap.set("n", "<F5>", function()
  require("dap").continue()
end)
vim.keymap.set("n", "<F9>", function()
  require("dap").step_over()
end)
vim.keymap.set("n", "<F8>", function()
  require("dap").step_into()
end)
vim.keymap.set("n", "<F7>", function()
  require("dap").step_out()
end)
