local TREE_LIST_STYLE = 3
local BANNER_HIDDEN = 0
local EXPLORER_WIDTH_PERCENT = 25
local BROWSE_SPLIT_REUSE_WINDOW = 0
local KEEP_ALTERNATE_FILE = 1
local DIRECTORY_SUFFIX_PATTERN = "/$"
local NO_PREVIOUS_WINDOW = 0

vim.g.netrw_liststyle = TREE_LIST_STYLE
vim.g.netrw_banner = BANNER_HIDDEN
vim.g.netrw_winsize = EXPLORER_WIDTH_PERCENT
vim.g.netrw_browse_split = BROWSE_SPLIT_REUSE_WINDOW
vim.g.netrw_altfile = KEEP_ALTERNATE_FILE

local function resolve_entry_path(entry_name)
  return vim.fs.joinpath(vim.b.netrw_curdir or vim.fn.getcwd(), entry_name)
end

local function create_directory(path)
  vim.fn.mkdir(path, "p")
  vim.cmd.edit()
end

local function open_in_previous_window(path)
  if vim.fn.winnr("#") ~= NO_PREVIOUS_WINDOW then
    vim.cmd.wincmd("p")
  end
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

local function create_file(path)
  local file = io.open(path, "w")
  if not file then
    vim.notify("Failed to create: " .. path, vim.log.levels.ERROR)
    return
  end
  file:close()
  open_in_previous_window(path)
end

-- netrw's own `%` opens the new file inside the explorer window, ignoring netrw_browse_split.
local function create_entry()
  local entry_name = vim.fn.input("Enter filename: ")
  if entry_name == "" then
    return
  end
  local path = resolve_entry_path(entry_name)
  if vim.uv.fs_stat(path) then
    vim.notify("Already exists: " .. entry_name, vim.log.levels.WARN)
    return
  end
  if entry_name:match(DIRECTORY_SUFFIX_PATTERN) then
    create_directory(path)
  else
    create_file(path)
  end
end

local function map_netrw_keys()
  vim.keymap.set("n", "%", create_entry, { buffer = true, silent = true, desc = "Create file in previous window" })
end

vim.keymap.set("n", "<leader>e", "<cmd>Lexplore<cr>", { silent = true, desc = "Toggle file explorer" })

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("netrw_keys", { clear = true }),
  pattern = "netrw",
  callback = map_netrw_keys,
})
