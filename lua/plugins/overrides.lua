if false then
  return {}
else
  return {
    { "folke/snacks.nvim", opts = { dashboard = { enabled = false } } },
    {
      "nvim-mini/mini.animate",
      enabled = false,
    },

    {
      "karb94/neoscroll.nvim",
      enabled = false,
    },

    {
      "sphamba/smear-cursor.nvim",
      event = "VeryLazy",
      enabled = false,
    },

    {
      "folke/persistence.nvim",
      enabled = false,
    },

    {
      "folke/snacks.nvim",
      opts = {
        picker = { sources = { notifications = { win = { preview = { wo = { wrap = true } } } } } },
      },
    },

    {
      "akinsho/bufferline.nvim",
      opts = {
        options = {
          always_show_bufferline = true,
        },
      },
    },
  }
end
