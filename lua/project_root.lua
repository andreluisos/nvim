local M = {}

local ROOT_MARKERS = { ".git" }

function M.resolve()
  return vim.fs.root(0, ROOT_MARKERS) or vim.fn.getcwd()
end

return M
