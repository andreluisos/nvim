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
        ---
        --- Async Status Component
        ---
        -- 1. Define the cache variable.
        -- We'll give it a default value while we wait for the first run.
        vim.g.my_status_stats = " ... 󰍛 ... 󰓡 ..."
        -- 2. Define the asynchronous updater function
        local function update_stats()
          local awk_cmd = [[
            awk '
              FILENAME == "/proc/meminfo" {
                if (/MemTotal:/) { ram_total=$2 }
                if (/MemAvailable:/) { ram_available=$2 }
                if (/SwapTotal:/) { swap_total=$2 }
                if (/SwapFree:/) { swap_free=$2 }
                next
              }
              FILENAME == "/sys/class/hwmon/hwmon5/temp1_input" {
                cpu_temp = $1 / 1000
                next
              }
              END {
                ram_percent = ((ram_total - ram_available) * 100 / ram_total)
                swap_used = swap_total - swap_free
                swap_percent = (swap_total == 0 ? 0 : (swap_used * 100 / swap_total))
                printf " %.0f°C 󰍛 %.0f%%%% 󰓡 %.0f%%%%", cpu_temp, ram_percent, swap_percent
              }
            ' /proc/meminfo /sys/class/hwmon/hwmon5/temp1_input
          ]]
          -- Use vim.fn.jobstart for non-blocking execution
          vim.fn.jobstart({ "sh", "-c", awk_cmd }, {
            stdout_buffered = true,
            -- When the command finishes, on_stdout runs
            on_stdout = function(_, data)
              if data[1] then
                -- Trim whitespace from the output
                local stats = data[1]:gsub("^%s*(.-)%s*$", "%1")
                if stats ~= "" and stats ~= vim.g.my_status_stats then
                  vim.g.my_status_stats = stats
                  vim.cmd.redrawstatus() -- Force lualine to update
                end
              end
            end,
          })
        end
        -- 3. Create and start the timer
        -- Create a timer that will call our function
        ---@diagnostic disable-next-line: undefined-field
        local stats_timer = vim.loop.new_timer()
        -- Start the timer
        -- 0: Start immediately on load
        -- 5000: Repeat every 5000ms (5 seconds)
        if not stats_timer then
          vim.notify("Lualine: Error creating stats timer", vim.log.levels.ERROR)
          return opts -- Return the original opts table
        end
        stats_timer:start(0, 5000, vim.schedule_wrap(update_stats))
        -- 4. Define the lualine component (now 100% non-blocking)
        local ram_swap_cpu_component = {
          function()
            -- This is now instant. It just reads the global variable.
            return vim.g.my_status_stats
          end,
          color = function()
            if package.loaded["Snacks"] and Snacks.util and Snacks.util.color then
              return { fg = Snacks.util.color("Comment") }
            end
            return { fg = "#9e9e9e" } -- Fallback grey
          end,
        }
        ---
        --- End Async Component
        ---
        table.insert(opts.sections.lualine_y, ram_swap_cpu_component)
        return opts
      end,
    },
    {
      "akinsho/bufferline.nvim",
      opts = {
        options = {
          -- Disable the default tab filter
          filter_by_tab = false,
          -- Use your custom CWD-based filter
          custom_filter = function(buf_number)
            local buf_name = vim.api.nvim_buf_get_name(buf_number)
            if buf_name == "" then
              return true -- Always show unnamed buffers
            end
            if not not buf_name:find(vim.fn.getcwd(), 0, true) then
              return true
            end
          end,
          -- START: Updated sort_by function
          sort_by = function(buffer_a, buffer_b)
            -- Use vim.fn.getftime() to get the modification timestamp
            -- It's simpler and linter-friendly.
            local mod_a = vim.fn.getftime(buffer_a.path) or 0
            local mod_b = vim.fn.getftime(buffer_b.path) or 0
            return mod_a > mod_b
          end,
          -- END: Updated sort_by function
        },
      },
    },
  }
end
