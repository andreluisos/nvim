local LIVE_COMPLETION_COMMANDS = { find = true, buffer = true, Recent = true }
local WILD_MODE = "noselect:lastused,full"
local FUZZY_WILD_OPTION = "fuzzy"
local COMMAND_LINE_TYPE = ":"
local COMMAND_NAME_PATTERN = "^%s*(%a+)%s"

local function typed_command_name()
  return vim.fn.getcmdline():match(COMMAND_NAME_PATTERN) or ""
end

local function trigger_live_completion()
  if vim.fn.getcmdtype() == COMMAND_LINE_TYPE and LIVE_COMPLETION_COMMANDS[typed_command_name()] then
    vim.fn.wildtrigger()
  end
end

vim.o.wildmode = WILD_MODE
vim.opt.wildoptions:append(FUZZY_WILD_OPTION)

vim.api.nvim_create_autocmd("CmdlineChanged", {
  group = vim.api.nvim_create_augroup("command_line_completion", { clear = true }),
  callback = trigger_live_completion,
})
