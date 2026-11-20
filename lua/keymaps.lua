local SPLIT_DIRECTIONS = { h = "left", j = "below", k = "above", l = "right" }

vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { silent = true, desc = "Write buffer" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { silent = true, desc = "Quit window" })
vim.keymap.set("n", "U", "<c-r>", { silent = true, desc = "Redo" })

for direction_key, direction_name in pairs(SPLIT_DIRECTIONS) do
  vim.keymap.set(
    "n",
    "<C-" .. direction_key .. ">",
    "<cmd>wincmd " .. direction_key .. "<cr>",
    { silent = true, desc = "Move to " .. direction_name .. " split" }
  )
end
