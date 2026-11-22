local blink = require("blink.cmp")

local DOCUMENTATION_DELAY_MILLISECONDS = 200
local COMMAND_LINE_TYPE = ":"

local function is_command_line()
  return vim.fn.getcmdtype() == COMMAND_LINE_TYPE
end

blink.setup({
  appearance = { nerd_font_variant = "mono" },
  completion = {
    menu = { draw = { treesitter = { "lsp" } } },
    documentation = { auto_show = true, auto_show_delay_ms = DOCUMENTATION_DELAY_MILLISECONDS },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer", "ripgrep" },
    providers = {
      ripgrep = { module = "blink-ripgrep", name = "Ripgrep" },
    },
  },
  cmdline = {
    keymap = { preset = "cmdline", ["<Right>"] = false, ["<Left>"] = false },
    completion = {
      list = { selection = { preselect = false } },
      menu = { auto_show = is_command_line },
      ghost_text = { enabled = true },
    },
  },
  keymap = {
    preset = "enter",
    ["<C-y>"] = { "select_and_accept" },
    ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
  },
})
