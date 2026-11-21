local NO_BUFFER = -1
local LISTED = 1
local UNSAVED_CHANGES_MESSAGE = "Buffer has unsaved changes; write it or use :bd!"

local function find_replacement(buffer)
  local alternate = vim.fn.bufnr("#")
  if alternate ~= NO_BUFFER and alternate ~= buffer and vim.fn.buflisted(alternate) == LISTED then
    return alternate
  end
  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = LISTED })) do
    if info.bufnr ~= buffer then
      return info.bufnr
    end
  end
  return vim.api.nvim_create_buf(true, false)
end

local function show_in_windows_of(buffer, replacement)
  for _, window in ipairs(vim.fn.win_findbuf(buffer)) do
    vim.api.nvim_win_set_buf(window, replacement)
  end
end

local function close_buffer_keep_layout()
  local buffer = vim.api.nvim_get_current_buf()
  if vim.bo[buffer].modified then
    vim.notify(UNSAVED_CHANGES_MESSAGE, vim.log.levels.WARN)
    return
  end
  show_in_windows_of(buffer, find_replacement(buffer))
  vim.api.nvim_buf_delete(buffer, {})
end

vim.keymap.set("n", "<leader>bd", close_buffer_keep_layout, { silent = true, desc = "Close buffer, keep layout" })
