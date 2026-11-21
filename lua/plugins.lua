local GITHUB_URL = "https://github.com/"

local function github_plugin(repository, version)
  return { src = GITHUB_URL .. repository, version = version }
end

vim.pack.add({
  github_plugin("mason-org/mason.nvim", vim.version.range("2")),
  github_plugin("neovim/nvim-lspconfig", vim.version.range("2")),
  github_plugin("mfussenegger/nvim-jdtls"),
  github_plugin("mrcjkb/rustaceanvim", vim.version.range("9")),
  github_plugin("b0o/SchemaStore.nvim"),
  github_plugin("nvim-lua/plenary.nvim"),
  github_plugin("NeogitOrg/neogit", vim.version.range("3")),
  github_plugin("sindrets/diffview.nvim"),
  github_plugin("folke/snacks.nvim", vim.version.range("2")),
  github_plugin("folke/which-key.nvim", vim.version.range("3")),
})
