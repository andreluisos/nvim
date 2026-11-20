local M = {}

local ALL_FILES_GLOB = "**/*"
local IGNORED_PATH_PATTERNS = { "node_modules", "%.git", "%.cache", "dist", "build", "%.tmp", "%.log" }

local function is_ignored(path)
  for _, pattern in ipairs(IGNORED_PATH_PATTERNS) do
    if path:match(pattern) then
      return true
    end
  end
  return false
end

local function is_listable_file(path)
  return vim.fn.isdirectory(path) == 0 and not is_ignored(path)
end

local function list_project_files()
  return vim.tbl_filter(is_listable_file, vim.fn.glob(ALL_FILES_GLOB, true, true))
end

function M.find_files(query, _is_completion)
  return vim.fn.matchfuzzy(list_project_files(), query)
end

vim.o.findfunc = "v:lua.require'find'.find_files"
vim.keymap.set("n", "<leader>f", ":find ", { desc = "Find file" })

return M
