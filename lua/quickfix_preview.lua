local file_preview = require("file_preview")

local QUICKFIX_WINDOW_TYPE = "quickfix"
local NO_BUFFER = 0

local function preview_current_item()
  if vim.fn.win_gettype() ~= QUICKFIX_WINDOW_TYPE then
    return
  end
  local item = vim.fn.getqflist()[vim.fn.line(".")]
  if item == nil or item.bufnr == NO_BUFFER then
    file_preview.close()
    return
  end
  file_preview.show_line(vim.api.nvim_buf_get_name(item.bufnr), item.lnum)
end

local buffer_group = vim.api.nvim_create_augroup("quickfix_preview_buffer", { clear = true })

local function attach_preview(event)
  vim.api.nvim_clear_autocmds({ group = buffer_group, buffer = event.buf })
  vim.api.nvim_create_autocmd(
    "CursorMoved",
    { group = buffer_group, buffer = event.buf, callback = preview_current_item }
  )
  vim.api.nvim_create_autocmd(
    { "BufLeave", "WinLeave" },
    { group = buffer_group, buffer = event.buf, callback = file_preview.close }
  )
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("quickfix_preview", { clear = true }),
  pattern = "qf",
  callback = attach_preview,
})
