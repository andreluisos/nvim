local COMPLETION_SOURCES = "o,.,w"
local COMPLETION_MENU_OPTIONS = { "menuone", "noselect", "popup", "fuzzy" }
local NO_SELECTION = -1
local ACCEPT_KEYS = "<C-y>"
local NEWLINE_KEYS = "<CR>"

local function has_selected_item()
  return vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected ~= NO_SELECTION
end

local function accept_or_newline()
  if has_selected_item() then
    return ACCEPT_KEYS
  end
  return NEWLINE_KEYS
end

vim.o.autocomplete = true
vim.o.complete = COMPLETION_SOURCES
vim.opt.completeopt = COMPLETION_MENU_OPTIONS

vim.keymap.set("i", "<CR>", accept_or_newline, { expr = true, desc = "Accept completion or insert newline" })
