-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymap that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("n", "<leader>e", ":Ex<CR>", { desc = "Open netrw" })
