local project_root = require("project_root")
local snacks = require("snacks")

local PICKER_INPUT_FILETYPE = "snacks_picker_input"

snacks.setup({ picker = { enabled = true } })

-- The native completion menu swallows TextChangedI, so the picker would stop filtering.
local function disable_autocomplete()
  vim.opt_local.autocomplete = false
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("picker_input", { clear = true }),
  pattern = PICKER_INPUT_FILETYPE,
  callback = disable_autocomplete,
})

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
