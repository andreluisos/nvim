local YANK_OPERATOR = "y"
local UNNAMED_REGISTER = ""
local SYSTEM_CLIPBOARD_REGISTER = "+"

local function is_plain_yank(event)
  return event.operator == YANK_OPERATOR and event.regname == UNNAMED_REGISTER
end

local function copy_yank_to_system_clipboard()
  local event = vim.v.event
  if not is_plain_yank(event) then
    return
  end
  vim.fn.setreg(SYSTEM_CLIPBOARD_REGISTER, event.regcontents, event.regtype)
end

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("system_clipboard_yank", { clear = true }),
  desc = "Copy plain yanks to the system clipboard",
  callback = copy_yank_to_system_clipboard,
})
