local M = {}

local NAMESPACE = vim.api.nvim_create_namespace("file_preview")
local INVALID_HANDLE = -1
local WIDTH_RATIO = 0.5
local HEIGHT_RATIO = 0.6
local TOP_ROW = 1
local RIGHT_MARGIN = 2
local BORDER = "rounded"
local TITLE_FORMAT = " %s "
local FOCUS_HIGHLIGHT = "Visual"
local READABLE = 1
local FIRST_LINE = 1
local NO_FOCUS_LINE = 0
local NUL_AS_NEWLINE = "\n"
local NUL_REPLACEMENT = " "
local CENTER_CURSOR_COMMAND = "normal! zz"
local OPEN_ONLY_OPTIONS = { style = "minimal", focusable = false, noautocmd = true }

local preview_buffer = INVALID_HANDLE
local preview_window = INVALID_HANDLE

local function preview_height()
  return math.floor(vim.o.lines * HEIGHT_RATIO)
end

local function window_layout(path)
  local width = math.floor(vim.o.columns * WIDTH_RATIO)
  return {
    relative = "editor",
    row = TOP_ROW,
    col = vim.o.columns - width - RIGHT_MARGIN,
    width = width,
    height = preview_height(),
    border = BORDER,
    title = string.format(TITLE_FORMAT, path),
  }
end

local function read_preview_lines(path, last_line)
  return vim.tbl_map(function(line)
    local sanitized = line:gsub(NUL_AS_NEWLINE, NUL_REPLACEMENT)
    return sanitized
  end, vim.fn.readfile(path, "", last_line))
end

local function ensure_buffer()
  if not vim.api.nvim_buf_is_valid(preview_buffer) then
    preview_buffer = vim.api.nvim_create_buf(false, true)
  end
  return preview_buffer
end

local function fill_buffer(buffer, path, last_line)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, read_preview_lines(path, last_line))
  vim.bo[buffer].syntax = vim.filetype.match({ filename = path }) or ""
end

local function ensure_window(buffer, path)
  local layout = window_layout(path)
  if vim.api.nvim_win_is_valid(preview_window) then
    vim.api.nvim_win_set_config(preview_window, layout)
  else
    preview_window = vim.api.nvim_open_win(buffer, false, vim.tbl_extend("force", layout, OPEN_ONLY_OPTIONS))
  end
  return preview_window
end

local function place_cursor(window, buffer, line)
  vim.api.nvim_buf_clear_namespace(buffer, NAMESPACE, 0, -1)
  if line == NO_FOCUS_LINE then
    vim.api.nvim_win_set_cursor(window, { FIRST_LINE, 0 })
    return
  end
  vim.api.nvim_buf_set_extmark(buffer, NAMESPACE, line - 1, 0, { line_hl_group = FOCUS_HIGHLIGHT })
  vim.api.nvim_win_set_cursor(window, { line, 0 })
  vim.api.nvim_win_call(window, function()
    vim.cmd(CENTER_CURSOR_COMMAND)
  end)
end

function M.close()
  if vim.api.nvim_win_is_valid(preview_window) then
    vim.api.nvim_win_close(preview_window, true)
  end
  preview_window = INVALID_HANDLE
end

local function show(path, line)
  if vim.fn.filereadable(path) ~= READABLE then
    M.close()
    return
  end
  local buffer = ensure_buffer()
  fill_buffer(buffer, path, line + preview_height())
  local window = ensure_window(buffer, path)
  place_cursor(window, buffer, math.min(line, vim.api.nvim_buf_line_count(buffer)))
end

function M.show_file(path)
  show(path, NO_FOCUS_LINE)
end

function M.show_line(path, line)
  show(path, math.max(line, FIRST_LINE))
end

return M
