local project_root = require("project_root")
local snacks = require("snacks")

snacks.setup({ picker = { enabled = true } })

local function open_picker(source)
  return function()
    snacks.picker[source]()
  end
end

local function open_picker_in(source, resolve_directory)
  return function()
    snacks.picker[source]({ cwd = resolve_directory() })
  end
end

vim.keymap.set("n", "<leader><space>", open_picker_in("files", project_root.resolve), { desc = "Find file (root)" })
vim.keymap.set("n", "<leader>ff", open_picker_in("files", project_root.resolve), { desc = "Find file (root)" })
vim.keymap.set("n", "<leader>fF", open_picker_in("files", vim.fn.getcwd), { desc = "Find file (cwd)" })
vim.keymap.set("n", "<leader>fr", open_picker("recent"), { desc = "Recent files" })
vim.keymap.set("n", "<leader>,", open_picker("buffers"), { desc = "Buffers" })
vim.keymap.set("n", "<leader>fb", open_picker("buffers"), { desc = "Buffers" })
vim.keymap.set("n", "<leader>/", open_picker_in("grep", project_root.resolve), { desc = "Grep (root)" })
vim.keymap.set("n", "<leader>sg", open_picker_in("grep", project_root.resolve), { desc = "Grep (root)" })
vim.keymap.set("n", "<leader>sG", open_picker_in("grep", vim.fn.getcwd), { desc = "Grep (cwd)" })
vim.keymap.set(
  { "n", "x" },
  "<leader>sw",
  open_picker_in("grep_word", project_root.resolve),
  { desc = "Grep word or selection (root)" }
)
