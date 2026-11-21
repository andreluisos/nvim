local command_line_completion = require("command_line_completion")
local file_preview = require("file_preview")

local NO_SELECTION = -1
local FIRST_MATCH = 1
local ZERO_BASED_OFFSET = 1
local COMMAND_LINE_MODE = "c"

local function highlighted_match()
  local info = vim.fn.cmdcomplete_info()
  local matches = info.matches or {}
  local selected = info.selected or NO_SELECTION
  if selected == NO_SELECTION then
    return matches[FIRST_MATCH] or ""
  end
  return matches[selected + ZERO_BASED_OFFSET] or ""
end

local function preview_highlighted_match()
  if vim.fn.mode() ~= COMMAND_LINE_MODE or not command_line_completion.is_live_command() then
    return
  end
  file_preview.show_file(highlighted_match())
  vim.cmd.redraw()
end

local function schedule_preview()
  if command_line_completion.is_live_command() then
    vim.schedule(preview_highlighted_match)
  end
end

local preview_group = vim.api.nvim_create_augroup("command_line_preview", { clear = true })
vim.api.nvim_create_autocmd("CmdlineChanged", { group = preview_group, callback = schedule_preview })
vim.api.nvim_create_autocmd("CmdlineLeave", { group = preview_group, callback = file_preview.close })
