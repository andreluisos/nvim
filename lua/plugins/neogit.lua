return {
  "NeogitOrg/neogit",
  enabled = true,
  lazy = true,
  dependencies = {
    -- Only one of these is needed.
    "sindrets/diffview.nvim", -- optional

    -- For a custom log pager
    "m00qek/baleia.nvim", -- optional

    -- Only one of these is needed.
    "folke/snacks.nvim", -- optional
  },
  cmd = "Neogit",
  keys = {
    { "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI" },
  },
}
