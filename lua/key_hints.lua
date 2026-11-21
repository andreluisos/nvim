local which_key = require("which-key")

local PRESET = "helix"
local HINT_MODES = { "n", "x" }

which_key.setup({
  preset = PRESET,
  spec = {
    {
      mode = HINT_MODES,
      { "<leader>a", group = "ai" },
      { "<leader>b", group = "buffer" },
      { "<leader>f", group = "file/find" },
      { "<leader>g", group = "git" },
      { "<leader>s", group = "search" },
      { "<leader>u", group = "ui" },
      { "[", group = "prev" },
      { "]", group = "next" },
      { "g", group = "goto" },
      { "z", group = "fold" },
    },
  },
})
