return {
  {
    "nvim-lualine/lualine.nvim",
    -- Using opts as a function allows us to modify LazyVim's default
    -- settings without completely overwriting everything else.
    opts = function(_, opts)
      -- Empty out the lualine_z section to remove the time
      opts.sections.lualine_z = {}
    end,
  },
}
