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
local CLOSING_CHARACTERS =
  { [")"] = true, ["]"] = true, ["}"] = true, ['"'] = true, ["'"] = true, ["`"] = true, [">"] = true }
local OPENING_CHARACTERS =
  { ["("] = true, ["["] = true, ["{"] = true, ['"'] = true, ["'"] = true, ["`"] = true, ["<"] = true }
local MOVE_RIGHT_KEYS = "<C-g>U<Right>"
local MOVE_LEFT_KEYS = "<C-g>U<Left>"

local function has_selected_item()
  return vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected ~= NO_SELECTION
end

local function accept_or_newline()
  if has_selected_item() then
    return ACCEPT_KEYS
  end
  return NEWLINE_KEYS
end

local function character_at(column)
  return vim.api.nvim_get_current_line():sub(column, column)
end

local function closing_character_follows()
  return CLOSING_CHARACTERS[character_at(vim.fn.col("."))] == true
end

local function opening_character_precedes()
  return OPENING_CHARACTERS[character_at(vim.fn.col(".") - 1)] == true
end

local FORWARD_NAVIGATION = {
  menu_keys = NEXT_ITEM_KEYS,
  direction = FORWARD,
  can_tab_out = closing_character_follows,
  tab_out_keys = MOVE_RIGHT_KEYS,
  fallback_keys = TAB_KEYS,
}

local BACKWARD_NAVIGATION = {
  menu_keys = PREVIOUS_ITEM_KEYS,
  direction = BACKWARD,
  can_tab_out = opening_character_precedes,
  tab_out_keys = MOVE_LEFT_KEYS,
  fallback_keys = SHIFT_TAB_KEYS,
}

-- Replaces the built-in Tab/Shift-Tab snippet mappings, so snippet jumping is kept before tabout.
local function build_tab_handler(navigation)
  return function()
    if vim.fn.pumvisible() == 1 then
      return navigation.menu_keys
    end
    if vim.snippet.active({ direction = navigation.direction }) then
      return string.format(SNIPPET_JUMP_FORMAT, navigation.direction)
    end
    if navigation.can_tab_out() then
      return navigation.tab_out_keys
    end
    return navigation.fallback_keys
  end
end

vim.o.autocomplete = true
vim.o.complete = COMPLETION_SOURCES
vim.opt.completeopt = COMPLETION_MENU_OPTIONS

vim.keymap.set("i", "<CR>", accept_or_newline, { expr = true, desc = "Accept completion or insert newline" })
vim.keymap.set(
  "i",
  TAB_KEYS,
  build_tab_handler(FORWARD_NAVIGATION),
  { expr = true, desc = "Next completion item, snippet jump, tab out, or Tab" }
)
vim.keymap.set(
  "i",
  SHIFT_TAB_KEYS,
  build_tab_handler(BACKWARD_NAVIGATION),
  { expr = true, desc = "Previous completion item, snippet jump, tab back, or Shift-Tab" }
)
