local project_root = require("project_root")

local GREP_PROMPT = "Grep: "
local FIXED_STRINGS_FLAG = "--fixed-strings"
local END_OF_OPTIONS = "--"
local SINGLE_LINE = 1
local MULTILINE_SELECTION_MESSAGE = "Grep needs a single-line selection"
local VISUAL_MODES = { v = true, V = true, ["\22"] = true }

vim.o.grepprg = "rg --vimgrep --smart-case --hidden"
vim.o.grepformat = "%f:%l:%c:%m"

local function directory_from_cwd(directory)
  return vim.fs.relpath(vim.fn.getcwd(), directory) or directory
end

local function build_grep_arguments(search)
  local arguments = vim.list_extend({}, search.flags)
  return vim.list_extend(arguments, { END_OF_OPTIONS, search.pattern, directory_from_cwd(search.directory) })
end

local function run_grep(search)
  local escaped_arguments = vim.tbl_map(function(argument)
    return vim.fn.shellescape(argument, true)
  end, build_grep_arguments(search))
  vim.cmd("silent grep! " .. table.concat(escaped_arguments, " "))
  vim.cmd.copen()
end

local function prompt_for_grep_in(resolve_directory)
  return function()
    local directory = resolve_directory()
    vim.ui.input({ prompt = GREP_PROMPT }, function(pattern)
      if not pattern or pattern == "" then
        return
      end
      run_grep({ pattern = pattern, directory = directory, flags = {} })
    end)
  end
end

local function word_or_selection()
  local mode = vim.fn.mode()
  if VISUAL_MODES[mode] then
    return vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
  end
  return { vim.fn.expand("<cword>") }
end

local function grep_word_or_selection()
  local lines = word_or_selection()
  if #lines ~= SINGLE_LINE then
    vim.notify(MULTILINE_SELECTION_MESSAGE, vim.log.levels.WARN)
    return
  end
  if lines[1] == "" then
    return
  end
  run_grep({ pattern = lines[1], directory = project_root.resolve(), flags = { FIXED_STRINGS_FLAG } })
end

vim.keymap.set("n", "<leader>/", prompt_for_grep_in(project_root.resolve), { silent = true, desc = "Grep (root)" })
vim.keymap.set("n", "<leader>sg", prompt_for_grep_in(project_root.resolve), { silent = true, desc = "Grep (root)" })
vim.keymap.set("n", "<leader>sG", prompt_for_grep_in(vim.fn.getcwd), { silent = true, desc = "Grep (cwd)" })
vim.keymap.set(
  { "n", "x" },
  "<leader>sw",
  grep_word_or_selection,
  { silent = true, desc = "Grep word or selection (root)" }
)
