-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- [[ DAP ]]
vim.keymap.set('n', '<F5>', function()
  require('dap').continue()
end)
vim.keymap.set('n', '<F9>', function()
  require('dap').step_over()
end)
vim.keymap.set('n', '<F8>', function()
  require('dap').step_into()
end)
vim.keymap.set('n', '<F7>', function()
  require('dap').step_out()
end)
