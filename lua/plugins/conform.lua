return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed =
          vim.tbl_extend("force", opts.ensure_installed, { "google-java-format", "prettier", "black", "clang-format" })
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        ["remove_blank_lines"] = {
          -- This uses sed to find 2 or more newlines and replace them with one.
          -- To remove ALL blank lines inside a method, a more aggressive
          -- regex might be needed, but this is a common starting point.
          command = "sed",
          args = { "/^ *$/d" },
        },
        ["google-java-format"] = {
          -- prepend_args = { "-a" },
        },
        ["clang-format"] = {
          prepend_args = { "-style=Google", "--tab-width=4" },
        },
      },
      formatters_by_ft = {
        java = { "google-java-format" },
        python = { "black" },
        typescript = { "prettier" },
        javascript = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
      },
    },
  },
}
