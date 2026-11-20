local YANK_HIGHLIGHT_DURATION_MILLISECONDS = 200
local FIRST_LINE = 1
local LAST_CURSOR_MARK = '"'

local function highlight_yanked_text()
  vim.hl.on_yank({ timeout = YANK_HIGHLIGHT_DURATION_MILLISECONDS, visual = true })
end

local function center_cursor_line()
  vim.cmd("normal! zz")
end

local function restore_last_cursor_position(event)
  local last_position = vim.api.nvim_buf_get_mark(event.buf, LAST_CURSOR_MARK)
  local last_line = last_position[1]
  if last_line < FIRST_LINE or last_line > vim.api.nvim_buf_line_count(event.buf) then
    return
  end
  vim.api.nvim_win_set_cursor(0, last_position)
  -- Deferred so the centering applies after the window has rendered.
  vim.schedule(center_cursor_line)
end

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  desc = "Highlight selection on yank",
  callback = highlight_yanked_text,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("restore_cursor", { clear = true }),
  desc = "Restore cursor to last edit position",
  callback = restore_last_cursor_position,
})
