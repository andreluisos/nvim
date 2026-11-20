vim.o.grepprg = "rg --vimgrep --smart-case --hidden"
vim.o.grepformat = "%f:%l:%c:%m"

local function grep_into_quickfix(pattern)
  if not pattern or pattern == "" then
    return
  end
  vim.cmd("silent grep! " .. vim.fn.shellescape(pattern, true))
  vim.cmd.copen()
end

local function prompt_for_grep()
  vim.ui.input({ prompt = "Grep: " }, grep_into_quickfix)
end

vim.keymap.set("n", "<leader>g", prompt_for_grep, { silent = true, desc = "Grep project" })
