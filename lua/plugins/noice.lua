local active = true
if active then
  return {
    "folke/noice.nvim",
    opts = {
      lsp = {
        progress = { enabled = false },
      },
    },
  }
end
