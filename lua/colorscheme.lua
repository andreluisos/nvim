local onedark = require("onedark")

local ONEDARK_OPTIONS = {
  style = "darker",
  transparent = true,
  term_colors = true,
  ending_tildes = false,
  code_style = {
    comments = "italic",
    keywords = "bold",
    functions = "italic,bold",
    strings = "none",
    variables = "none",
  },
  diagnostics = {
    darker = true,
    undercurl = true,
    background = true,
  },
}

onedark.setup(ONEDARK_OPTIONS)
vim.cmd.colorscheme("onedark")
