local claudecode = require("claudecode")

local TERMINAL_WORKING_DIRECTORY = "/work"
local NETRW_FILETYPE = "netrw"

claudecode.setup({ terminal = { cwd = TERMINAL_WORKING_DIRECTORY } })

local function add_tree_selection_mapping(event)
  vim.keymap.set("n", "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", { buffer = event.buf, desc = "Add file" })
end

vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
vim.keymap.set("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
vim.keymap.set("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude" })
vim.keymap.set("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue Claude" })
vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current buffer" })
vim.keymap.set("x", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send to Claude" })
vim.keymap.set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("claude_code_tree", { clear = true }),
  pattern = NETRW_FILETYPE,
  callback = add_tree_selection_mapping,
})
