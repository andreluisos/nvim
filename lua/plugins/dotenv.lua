return {
  "ellisonleao/dotenv.nvim",
  config = function()
    require("dotenv").setup({
      enable_on_load = true,
      autocmd = "DirChanged",
    })

    -- The fix for the headless server architecture
    -- Forces the plugin to read the .env file when Neovide connects
    vim.api.nvim_create_autocmd("UIEnter", {
      pattern = "*",
      callback = function()
        -- The plugin registers the :Dotenv command.
        -- We trigger it silently to load the variables for the current tab.
        pcall(vim.cmd, "Dotenv")
      end,
    })
  end,
}
