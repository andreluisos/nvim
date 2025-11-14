if false then
  return {}
else
  return {
    {
      "nvim-mini/mini.animate",
      enabled = not vim.g.neovide,
    },

    {
      "karb94/neoscroll.nvim",
      enabled = not vim.g.neovide,
    },

    {
      "sphamba/smear-cursor.nvim",
      event = "VeryLazy",
      cond = vim.g.neovide == nil,
      opts = {
        cursor_color = "#AFD802",
        stiffness = 0.3,
        trailing_stiffness = 0.1,
        damping = 0.5,
        trailing_exponent = 5,
        never_draw_over_target = true,
        hide_target_hack = true,
        gamma = 1,
      },
      specs = {
        -- disable mini.animate cursor
        {
          "nvim-mini/mini.animate",
          optional = true,
          opts = {
            cursor = { enable = false },
          },
        },
      },
    },

    {
      "folke/snacks.nvim",
      opts = {
        picker = { sources = { notifications = { win = { preview = { wo = { wrap = true } } } } } },
      },
    },

    {
      "nvim-lualine/lualine.nvim",
      -- 'opts' here is a function that receives the *default* opts table
      -- from LazyVim. We can then modify it.
      opts = function(_, opts)
        -- 'opts' is the table with all the default sections
        -- We just need to add our component to the right section.
        local ram_swap_component = {
          function()
            local cmd =
              "free -m | awk 'NR==2 { ram_total=$2; ram_available=$7 } NR==3 { swap_total=$2; swap_used=$3 } END { printf \"󰍛 %.0f%%%% 󰓡 %.0f%%%%\", (ram_available * 100 / ram_total), (swap_total == 0 ? 0 : (swap_used * 100 / swap_total)) }'"
            local f = io.popen(cmd)
            if not f then
              return ""
            end
            local stats = f:read("*a")
            f:close()
            return stats:gsub("[\n\r]", "")
          end,
          color = function()
            if package.loaded["Snacks"] and Snacks.util and Snacks.util.color then
              return { fg = Snacks.util.color("Comment") }
            end
            return { fg = "#9e9e9e" } -- Fallback grey
          end,
        }
        -- Add your component to the 'lualine_y' section
        table.insert(opts.sections.lualine_y, ram_swap_component)
        -- Return the modified opts table
        return opts
      end,
    },
  }
end
