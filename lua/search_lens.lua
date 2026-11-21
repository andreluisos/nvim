local M = {}

local NAMESPACE = vim.api.nvim_create_namespace("search_lens")
local MAX_COUNT = 999
local COUNT_TIMEOUT_MILLISECONDS = 100
local MAX_COUNT_EXCEEDED = 2
local LENS_FORMAT = " [%d/%s]"
local LENS_HIGHLIGHT = "Comment"
local CURRENT_WINDOW = 0
local SEARCH_COMMAND_TYPES = { ["/"] = true, ["?"] = true }
local SEARCH_KEYS = { "n", "N", "*", "#", "g*", "g#" }
local SHOW_COMMAND = "<Cmd>lua require('search_lens').show()<CR>"

local lens_buffer = nil
local lens_line = nil

local function cursor_line()
  return vim.api.nvim_win_get_cursor(CURRENT_WINDOW)[1] - 1
end

local function format_total(count)
  if count.incomplete == MAX_COUNT_EXCEEDED then
    return ">" .. count.maxcount
  end
  return tostring(count.total)
end

function M.clear()
  if lens_buffer and vim.api.nvim_buf_is_valid(lens_buffer) then
    vim.api.nvim_buf_clear_namespace(lens_buffer, NAMESPACE, 0, -1)
  end
  lens_buffer = nil
  lens_line = nil
end

function M.show()
  M.clear()
  if vim.v.hlsearch == 0 then
    return
  end
  local succeeded, count = pcall(vim.fn.searchcount, {
    recompute = true,
    maxcount = MAX_COUNT,
    timeout = COUNT_TIMEOUT_MILLISECONDS,
  })
  if not succeeded or count.total == 0 then
    return
  end
  lens_buffer = vim.api.nvim_get_current_buf()
  lens_line = cursor_line()
  vim.api.nvim_buf_set_extmark(lens_buffer, NAMESPACE, lens_line, 0, {
    virt_text = { { string.format(LENS_FORMAT, count.current, format_total(count)), LENS_HIGHLIGHT } },
    virt_text_pos = "eol",
  })
end

local function clear_when_left()
  if not lens_buffer then
    return
  end
  local left = vim.v.hlsearch == 0 or vim.api.nvim_get_current_buf() ~= lens_buffer or cursor_line() ~= lens_line
  if left then
    M.clear()
  end
end

local function show_after_search_command()
  if not SEARCH_COMMAND_TYPES[vim.fn.getcmdtype()] or vim.v.event.abort then
    return
  end
  vim.schedule(M.show)
end

local function clear_search()
  vim.cmd.nohlsearch()
  M.clear()
end

for _, key in ipairs(SEARCH_KEYS) do
  vim.keymap.set("n", key, key .. SHOW_COMMAND, { silent = true, desc = "Search and show match index" })
end
vim.keymap.set("n", "<Esc>", clear_search, { silent = true, desc = "Clear search highlight" })

local lens_group = vim.api.nvim_create_augroup("search_lens", { clear = true })
vim.api.nvim_create_autocmd("CmdlineLeave", { group = lens_group, callback = show_after_search_command })
vim.api.nvim_create_autocmd("CursorMoved", { group = lens_group, callback = clear_when_left })
vim.api.nvim_create_autocmd("InsertEnter", { group = lens_group, callback = M.clear })

return M
