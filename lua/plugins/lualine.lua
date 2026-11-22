local CLOCK_FORMAT = "%d/%m/%Y %H:%M:%S"

local function render_escaped_system_status()
  return (require("custom.system_status").text():gsub("%%", "%%%%"))
end

return {
  {
    "nvim-lualine/lualine.nvim",
    -- Using opts as a function allows us to modify LazyVim's default
    -- settings without completely overwriting everything else.
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, "lsp_status")
      -- Replace the time in the lualine_z section with the system status and the full date and time
      opts.sections.lualine_z = { render_escaped_system_status, { "datetime", style = CLOCK_FORMAT } }
    end,
  },
}
