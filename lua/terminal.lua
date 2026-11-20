local TERMINAL_HEIGHT_DIVISOR = 4
local TOGGLE_KEYS = { "<C-/>", "<C-_>" }
local NO_WINDOW = -1
local SINGLE_WINDOW_COUNT = 1

local terminal_buffer = nil

local function has_terminal_buffer()
  return terminal_buffer ~= nil and vim.api.nvim_buf_is_valid(terminal_buffer)
end

local function find_terminal_window()
  if not has_terminal_buffer() then
    return NO_WINDOW
  end
  return vim.fn.bufwinid(terminal_buffer)
end

local function open_bottom_window()
  vim.cmd("botright split")
  vim.api.nvim_win_set_height(0, math.floor(vim.o.lines / TERMINAL_HEIGHT_DIVISOR))
end

local function show_terminal()
  open_bottom_window()
  if has_terminal_buffer() then
    vim.api.nvim_win_set_buf(0, terminal_buffer)
  else
    vim.cmd.terminal()
    terminal_buffer = vim.api.nvim_get_current_buf()
  end
  vim.cmd.startinsert()
end

local function hide_terminal(window)
  if #vim.api.nvim_tabpage_list_wins(0) == SINGLE_WINDOW_COUNT then
    vim.notify("Terminal is the only window; not hiding it", vim.log.levels.WARN)
    return
  end
  vim.api.nvim_win_hide(window)
end

local function toggle_terminal()
  local window = find_terminal_window()
  if window == NO_WINDOW then
    show_terminal()
  else
    hide_terminal(window)
  end
end

-- A finished shell would leave a dead buffer behind; drop it so the next toggle starts fresh.
local function forget_finished_terminal(event)
  if event.buf ~= terminal_buffer then
    return
  end
  terminal_buffer = nil
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(event.buf) then
      vim.api.nvim_buf_delete(event.buf, { force = true })
    end
  end)
end

for _, key in ipairs(TOGGLE_KEYS) do
  vim.keymap.set({ "n", "t" }, key, toggle_terminal, { silent = true, desc = "Toggle bottom terminal" })
end
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { silent = true, desc = "Leave terminal mode" })

vim.api.nvim_create_autocmd("TermClose", {
  group = vim.api.nvim_create_augroup("bottom_terminal", { clear = true }),
  desc = "Forget the bottom terminal when its shell exits",
  callback = forget_finished_terminal,
})
