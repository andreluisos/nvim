local function toggle_diffview()
  if require("diffview.lib").get_current_view() then
    vim.cmd("DiffviewClose")
    return
  end
  vim.cmd("DiffviewOpen")
end

require("neogit").setup({ integrations = { diffview = true } })

vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { silent = true, desc = "Open Neogit" })
vim.keymap.set("n", "<leader>gd", toggle_diffview, { silent = true, desc = "Toggle diff view" })
vim.keymap.set("n", "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", { silent = true, desc = "File history" })
