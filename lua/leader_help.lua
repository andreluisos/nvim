local M = {}

local ESCAPE_KEY = vim.keycode("<Esc>")
local ROW_FORMAT = "  %s  %s"
local WINDOW_BORDER = "rounded"
local WINDOW_TITLE = " <leader> "
local HORIZONTAL_PADDING = 2
local STATUSLINE_AND_BORDER_ROWS = 3
local CENTER_DIVISOR = 2

local function collect_leader_mappings()
  local leader = vim.g.mapleader
  local descriptions = {}
  for _, mappings in ipairs({ vim.api.nvim_buf_get_keymap(0, "n"), vim.api.nvim_get_keymap("n") }) do
    for _, mapping in ipairs(mappings) do
      local key = mapping.lhs:sub(#leader + 1)
      if vim.startswith(mapping.lhs, leader) and key ~= "" and descriptions[key] == nil then
        descriptions[key] = mapping.desc or mapping.rhs or ""
      end
    end
  end
  return descriptions
end

local function format_rows(descriptions)
  local keys = vim.tbl_keys(descriptions)
  table.sort(keys)
  return vim.tbl_map(function(key)
    return string.format(ROW_FORMAT, key, descriptions[key])
  end, keys)
end

local function open_help_window(rows)
  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, rows)
  local width = math.max(unpack(vim.tbl_map(vim.fn.strdisplaywidth, rows))) + HORIZONTAL_PADDING
  local window = vim.api.nvim_open_win(buffer, false, {
    relative = "editor",
    row = vim.o.lines - #rows - STATUSLINE_AND_BORDER_ROWS,
    col = math.floor((vim.o.columns - width) / CENTER_DIVISOR),
    width = width,
    height = #rows,
    style = "minimal",
    border = WINDOW_BORDER,
    title = WINDOW_TITLE,
  })
  vim.cmd.redraw()
  return window
end

local function run_leader_shortcut(key)
  if key == ESCAPE_KEY then
    return
  end
  vim.api.nvim_feedkeys(vim.g.mapleader .. key, "m", false)
end

function M.show()
  local rows = format_rows(collect_leader_mappings())
  if #rows == 0 then
    return
  end
  local window = open_help_window(rows)
  local key = vim.fn.getcharstr()
  vim.api.nvim_win_close(window, true)
  run_leader_shortcut(key)
end

vim.keymap.set("n", "<leader>", M.show, { silent = true, desc = "Show leader shortcuts" })

return M
