local TREE_LIST_STYLE = 3
local BANNER_HIDDEN = 0
local EXPLORER_WIDTH_PERCENT = 25
local BROWSE_SPLIT_REUSE_WINDOW = 0
local KEEP_ALTERNATE_FILE = 1
local DIRECTORY_SUFFIX_PATTERN = "/$"
local NO_PREVIOUS_WINDOW = 0
local TREE_INDENT = "| "
local PARENT_DIRECTORY_LINE = "../"
local DIRECTORY_SUFFIX = "/"
local CLASSIFIER_SUFFIX_PATTERN = "[*@]$"
local TOGGLE_DIRECTORY_KEY = "\r"
local CLOSED_WINDOW = -1

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

local function read_tree_lines()
  return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

local function relative_path_components(file_path)
  local relative_path = vim.fs.relpath(vim.fn.getcwd(), file_path)
  if not relative_path then
    return {}
  end
  return vim.split(relative_path, DIRECTORY_SUFFIX, { plain = true })
end

local function find_root_line(lines)
  for line_number, line in ipairs(lines) do
    if line ~= PARENT_DIRECTORY_LINE and not vim.startswith(line, TREE_INDENT) then
      return line_number
    end
  end
end

local function entry_name_at(line, depth)
  return (line:sub(#TREE_INDENT * depth + 1):gsub(CLASSIFIER_SUFFIX_PATTERN, ""))
end

-- Children of a tree line follow it directly, one indent deeper, until the indent shrinks.
local function find_child_line(lines, parent_line, depth, entry)
  local child_prefix = string.rep(TREE_INDENT, depth)
  for line_number = parent_line + 1, #lines do
    local line = lines[line_number]
    if not vim.startswith(line, child_prefix) then
      return nil
    end
    if entry_name_at(line, depth) == entry then
      return line_number
    end
  end
end

local function is_expanded(lines, line_number, depth)
  local next_line = lines[line_number + 1]
  return next_line ~= nil and vim.startswith(next_line, string.rep(TREE_INDENT, depth + 1))
end

local function reveal_path(components)
  local parent_line = find_root_line(read_tree_lines())
  for depth, component in ipairs(components) do
    local is_directory = depth < #components
    local entry = is_directory and component .. DIRECTORY_SUFFIX or component
    local line_number = parent_line and find_child_line(read_tree_lines(), parent_line, depth, entry)
    if not line_number then
      return
    end
    vim.api.nvim_win_set_cursor(0, { line_number, 0 })
    if is_directory and not is_expanded(read_tree_lines(), line_number, depth) then
      vim.cmd.normal(TOGGLE_DIRECTORY_KEY)
    end
    parent_line = line_number
  end
end

local function is_explorer_open()
  local explorer_buffer = vim.t.netrw_lexbufnr
  return explorer_buffer ~= nil and vim.fn.bufwinnr(explorer_buffer) ~= CLOSED_WINDOW
end

local function toggle_explorer()
  if is_explorer_open() then
    vim.cmd.Lexplore()
    return
  end
  local components = relative_path_components(vim.api.nvim_buf_get_name(0))
  vim.cmd.Lexplore()
  reveal_path(components)
end

local function map_netrw_keys()
  vim.keymap.set("n", "%", create_entry, { buffer = true, silent = true, desc = "Create file in previous window" })
end

vim.keymap.set("n", "<leader>e", toggle_explorer, { silent = true, desc = "Toggle file explorer at current file" })

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("netrw_keys", { clear = true }),
  pattern = "netrw",
  callback = map_netrw_keys,
})
