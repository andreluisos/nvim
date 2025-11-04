-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("n", "<leader>fC", function()
  -- %:p is the Neovim command-line modifier to get the full absolute path of the current file.
  local absolute_path = vim.fn.expand("%:p")

  -- vim.fn.setreg('+') sets the contents of the system clipboard (+)
  vim.fn.setreg("+", absolute_path)

  -- Provide a notification to the user that the operation was successful
  vim.notify("Copied absolute path to clipboard: " .. absolute_path, vim.log.levels.INFO, {
    title = "File Path Copied",
  })
end, {
  noremap = true,
  silent = true,
  desc = "Copy absolute file path to clipboard",
})

-- [[ DAP ]]
vim.keymap.set("n", "<F5>", function()
  require("dap").continue()
end)
vim.keymap.set("n", "<F9>", function()
  require("dap").step_over()
end)
vim.keymap.set("n", "<F8>", function()
  require("dap").step_into()
end)
vim.keymap.set("n", "<F7>", function()
  require("dap").step_out()
end)

local function commit_staged_non_blocking_system()
  -- 1. Construct the command arguments as a list (table)
  local cmd = {
    "opencode",
    "run",
    "Commit staged changes",
    "--model",
    "github-copilot/gpt-4.1",
  }
  vim.notify("Committing staged changes...", vim.log.levels.INFO, { title = "opencode" })
  -- 2. Execute the command asynchronously using vim.system()
  -- The options table can include a 'text' field for a callback function
  vim.system(cmd, { text = true }, function(result)
    -- This callback is executed when the command finishes
    if result.code == 0 then
      -- Log the success
      vim.notify("Staged changes committed.", vim.log.levels.INFO, { title = "opencode" })
      -- Optional: Display the output if you want to see the commit message
      -- print("opencode Output:\n" .. result.stdout)
    else
      -- Log the failure, including the exit code and any error output
      local error_msg = "Failed to commit staged changes. Exit code: " .. result.code
      if result.stderr and result.stderr ~= "" then
        error_msg = error_msg .. "\nError:\n" .. result.stderr
      end
      vim.notify(error_msg, vim.log.levels.ERROR, { title = "opencode" })
    end
  end)
end

vim.keymap.set("n", "<leader>gc", commit_staged_non_blocking_system, { desc = "Git commit staged changes" })
