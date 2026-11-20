local M = {}

local QUICKFIX_CLOSED = 0

function M.is_open()
  return vim.fn.getqflist({ winid = 0 }).winid ~= QUICKFIX_CLOSED
end

return M
