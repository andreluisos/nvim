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
      opts = function(_, opts)
        local ram_swap_cpu_component = {
          function()
            local ram_cmd =
              "free -m | awk 'NR==2 { ram_total=$2; ram_available=$7 } NR==3 { swap_total=$2; swap_used=$3 } END { printf \"󰍛 %.0f%%%% 󰓡 %.0f%%%%\", ((ram_total - ram_available) * 100 / ram_total), (swap_total == 0 ? 0 : (swap_used * 100 / swap_total)) }'"
            local f_ram = io.popen(ram_cmd)
            local ram_stats = ""
            if f_ram then
              ram_stats = f_ram:read("*a")
              f_ram:close()
              ram_stats = ram_stats:gsub("[\n\r]", "")
            end
            local cpu_cmd = "awk '{printf \" %.0f°C\", $1 / 1000}' /sys/class/hwmon/hwmon5/temp1_input"
            local f_cpu = io.popen(cpu_cmd)
            local cpu_temp = ""
            if f_cpu then
              cpu_temp = f_cpu:read("*a")
              f_cpu:close()
              cpu_temp = cpu_temp:gsub("[\n\r]", "")
            end
            return cpu_temp .. " " .. ram_stats
          end,
          color = function()
            if package.loaded["Snacks"] and Snacks.util and Snacks.util.color then
              return { fg = Snacks.util.color("Comment") }
            end
            return { fg = "#9e9e9e" } -- Fallback grey
          end,
        }
        table.insert(opts.sections.lualine_y, ram_swap_cpu_component)
        return opts
      end,
    },
  }
end
