local flash = require("flash")

local INCREMENTAL_SELECTION_ACTIONS = { ["<c-space>"] = "next", ["<BS>"] = "prev" }

flash.setup({})

local function select_incrementally()
  flash.treesitter({ actions = INCREMENTAL_SELECTION_ACTIONS })
end

vim.keymap.set({ "n", "x", "o" }, "s", flash.jump, { desc = "Flash" })
vim.keymap.set({ "n", "x", "o" }, "S", flash.treesitter, { desc = "Flash Treesitter" })
vim.keymap.set("o", "r", flash.remote, { desc = "Remote Flash" })
vim.keymap.set({ "o", "x" }, "R", flash.treesitter_search, { desc = "Treesitter Search" })
vim.keymap.set("c", "<c-s>", flash.toggle, { desc = "Toggle Flash Search" })
vim.keymap.set({ "n", "x", "o" }, "<c-space>", select_incrementally, { desc = "Treesitter Incremental Selection" })
