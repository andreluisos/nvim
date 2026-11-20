local PATH_SEPARATOR = ":"
local MASON_BIN_DIRECTORY = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")

local function is_on_path(directory)
  return vim.tbl_contains(vim.split(vim.env.PATH, PATH_SEPARATOR, { plain = true }), directory)
end

if vim.fn.isdirectory(MASON_BIN_DIRECTORY) == 1 and not is_on_path(MASON_BIN_DIRECTORY) then
  vim.env.PATH = MASON_BIN_DIRECTORY .. PATH_SEPARATOR .. vim.env.PATH
end
