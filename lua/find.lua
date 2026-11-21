local M = {}

local project_root = require("project_root")

local FILE_LIST_COMMAND = { "rg", "--files", "--hidden", "--glob", "!.git" }
local FIND_PROMPT = ":find "
local BUFFER_PROMPT = ":buffer "
local RECENT_PROMPT = ":Recent "
local READABLE = 1
local NO_RECENT_MATCH_MESSAGE = "No recent file matches: %s"

local search_directory = vim.fn.getcwd()
local cached_files = nil

local function path_from_cwd(path)
  return vim.fs.relpath(vim.fn.getcwd(), path) or path
end

local function list_files(directory)
  local result = vim.system(FILE_LIST_COMMAND, { cwd = directory, text = true }):wait()
  local files = vim.split(result.stdout, "\n", { trimempty = true })
  return vim.tbl_map(function(file)
    return path_from_cwd(vim.fs.joinpath(directory, file))
  end, files)
end

local function project_files()
  if cached_files == nil then
    cached_files = list_files(search_directory)
  end
  return cached_files
end

local function forget_cached_files()
  cached_files = nil
end

local function filter_fuzzy(items, query)
  if query == "" then
    return items
  end
  return vim.fn.matchfuzzy(items, query)
end

function M.find_files(query, _is_completion)
  return filter_fuzzy(project_files(), query)
end

local function is_readable(path)
  return vim.fn.filereadable(path) == READABLE
end

local function recent_files()
  return vim.tbl_map(path_from_cwd, vim.tbl_filter(is_readable, vim.v.oldfiles))
end

local function complete_recent_files(argument_lead)
  return filter_fuzzy(recent_files(), argument_lead)
end

local function resolve_recent_files(query)
  if is_readable(query) then
    return { query }
  end
  return complete_recent_files(query)
end

local function edit_recent_file(command)
  local matches = resolve_recent_files(command.args)
  if #matches == 0 then
    vim.notify(string.format(NO_RECENT_MATCH_MESSAGE, command.args), vim.log.levels.WARN)
    return
  end
  vim.cmd.edit(vim.fn.fnameescape(matches[1]))
end

local function open_find_prompt_in(resolve_directory)
  return function()
    search_directory = resolve_directory()
    return FIND_PROMPT
  end
end

vim.o.findfunc = "v:lua.require'find'.find_files"

vim.api.nvim_create_user_command(
  "Recent",
  edit_recent_file,
  { nargs = 1, complete = complete_recent_files, desc = "Edit a recent file" }
)
vim.api.nvim_create_autocmd("CmdlineEnter", {
  group = vim.api.nvim_create_augroup("find_file_cache", { clear = true }),
  callback = forget_cached_files,
})

vim.keymap.set(
  "n",
  "<leader><space>",
  open_find_prompt_in(project_root.resolve),
  { expr = true, desc = "Find file (root)" }
)
vim.keymap.set("n", "<leader>ff", open_find_prompt_in(project_root.resolve), { expr = true, desc = "Find file (root)" })
vim.keymap.set("n", "<leader>fF", open_find_prompt_in(vim.fn.getcwd), { expr = true, desc = "Find file (cwd)" })
vim.keymap.set("n", "<leader>fr", RECENT_PROMPT, { desc = "Recent files" })
vim.keymap.set("n", "<leader>,", BUFFER_PROMPT, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fb", BUFFER_PROMPT, { desc = "Buffers" })

return M
