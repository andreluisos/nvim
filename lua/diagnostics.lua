local QUICKFIX_CLOSED = 0

local function is_quickfix_open()
  return vim.fn.getqflist({ winid = 0 }).winid ~= QUICKFIX_CLOSED
end

local function toggle_diagnostics_list()
  if is_quickfix_open() then
    vim.cmd.cclose()
    return
  end
  vim.diagnostic.setqflist()
end

vim.keymap.set("n", "<leader>d", toggle_diagnostics_list, { silent = true, desc = "Toggle diagnostics quickfix" })
