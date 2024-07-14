return {
  { "nvimdev/dashboard-nvim", enabled = false },
  { "folke/noice.nvim",       enabled = false },
  { "folke/flash.nvim",       enabled = false },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.mapping = vim.tbl_deep_extend("force", opts.mapping, {
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        -- put here the keymaps that you want to change
      })
    end,
  },
}
