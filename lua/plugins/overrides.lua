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
    enabled = true,
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
    opts = function(_, opts)
      opts.options.always_show_bufferline = true
      -- Continue the explorer's window separator through the bufferline row so both lines share one column
      for _, offset in ipairs(opts.options.offsets) do
        if offset.filetype == "snacks_layout_box" then
          offset.separator = true
        end
      end
    end,
  },
}
