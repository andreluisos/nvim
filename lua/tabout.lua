local TAB_KEYS = "<Tab>"
local SHIFT_TAB_KEYS = "<S-Tab>"
local MOVE_RIGHT_KEYS = "<C-g>U<Right>"
local MOVE_LEFT_KEYS = "<C-g>U<Left>"
local CLOSING_CHARACTERS =
  { [")"] = true, ["]"] = true, ["}"] = true, ['"'] = true, ["'"] = true, ["`"] = true, [">"] = true }
local OPENING_CHARACTERS =
  { ["("] = true, ["["] = true, ["{"] = true, ['"'] = true, ["'"] = true, ["`"] = true, ["<"] = true }

local function character_at(column)
  return vim.api.nvim_get_current_line():sub(column, column)
end

local function closing_character_follows()
  return CLOSING_CHARACTERS[character_at(vim.fn.col("."))] == true
end

local function opening_character_precedes()
  return OPENING_CHARACTERS[character_at(vim.fn.col(".") - 1)] == true
end

-- blink.cmp runs these as the fallback once its menu and snippet actions do not apply.
local function build_tabout_handler(can_tab_out, tab_out_keys, fallback_keys)
  return function()
    if can_tab_out() then
      return tab_out_keys
    end
    return fallback_keys
  end
end

vim.keymap.set(
  "i",
  TAB_KEYS,
  build_tabout_handler(closing_character_follows, MOVE_RIGHT_KEYS, TAB_KEYS),
  { expr = true, desc = "Tab out of closing character, or Tab" }
)
vim.keymap.set(
  "i",
  SHIFT_TAB_KEYS,
  build_tabout_handler(opening_character_precedes, MOVE_LEFT_KEYS, SHIFT_TAB_KEYS),
  { expr = true, desc = "Tab back over opening character, or Shift-Tab" }
)
