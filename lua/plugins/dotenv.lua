return {
  "ellisonleao/dotenv.nvim",
  event = "VimEnter",
  config = function()
    require("dotenv").setup({
      enable_on_load = true,
      verbose = false,
    })
    vim.cmd("Dotenv")
  end,
}
