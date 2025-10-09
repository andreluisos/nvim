return {
  "mfussenegger/nvim-jdtls",
  opts = function(_, opts)
    table.insert(opts.cmd, "-Xms128m")
    table.insert(opts.cmd, "-Xmx512m")
  end,
}
