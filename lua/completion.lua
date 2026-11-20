local COMPLETION_SOURCES = "o,.,w"
local COMPLETION_MENU_OPTIONS = { "menuone", "noselect", "popup", "fuzzy" }
local NO_SELECTION = -1
local ACCEPT_KEYS = "<C-y>"
local NEWLINE_KEYS = "<CR>"
local NEXT_ITEM_KEYS = "<C-n>"
local PREVIOUS_ITEM_KEYS = "<C-p>"
local TAB_KEYS = "<Tab>"
local SHIFT_TAB_KEYS = "<S-Tab>"
local SNIPPET_JUMP_FORMAT = "<Cmd>lua vim.snippet.jump(%d)<CR>"
local FORWARD = 1
local BACKWARD = -1

local function has_selected_item()
  return vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected ~= NO_SELECTION
end

local function accept_or_newline()
  if has_selected_item() then
    return ACCEPT_KEYS
  end
  return NEWLINE_KEYS
end

-- Replaces the built-in Tab/Shift-Tab snippet mappings, so snippet jumping is kept as the fallback.
local function navigate_menu_or_snippet(menu_keys, direction, fallback_keys)
  return function()
    if vim.fn.pumvisible() == 1 then
      return menu_keys
    end
    if vim.snippet.active({ direction = direction }) then
      return string.format(SNIPPET_JUMP_FORMAT, direction)
    end
    return fallback_keys
  end
end

vim.o.autocomplete = true
vim.o.complete = COMPLETION_SOURCES
vim.opt.completeopt = COMPLETION_MENU_OPTIONS

vim.keymap.set("i", "<CR>", accept_or_newline, { expr = true, desc = "Accept completion or insert newline" })
vim.keymap.set(
  "i",
  TAB_KEYS,
  navigate_menu_or_snippet(NEXT_ITEM_KEYS, FORWARD, TAB_KEYS),
  { expr = true, desc = "Next completion item, snippet jump, or Tab" }
)
vim.keymap.set(
  "i",
  SHIFT_TAB_KEYS,
  navigate_menu_or_snippet(PREVIOUS_ITEM_KEYS, BACKWARD, SHIFT_TAB_KEYS),
  { expr = true, desc = "Previous completion item, snippet jump, or Shift-Tab" }
)
