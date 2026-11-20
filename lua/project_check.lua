local M = {}

local DIRECTORY_LINE_FORMAT = "Entering directory '%s'"
local DIRECTORY_ERROR_FORMAT = "%DEntering directory '%f'"
local IGNORE_OTHER_LINES_FORMAT = "%-G%.%#"
local QUICKFIX_TITLE_PREFIX = "Project check: "
local LINE_SEPARATOR = "\n"
local COLON_LOCATION_FORMAT = "%f:%l:%c: %m"
local VALID_ITEM = 1

local CARGO_CHECKER = {
  name = "cargo clippy",
  root_markers = { { "Cargo.lock" }, { "Cargo.toml" } },
  error_format = COLON_LOCATION_FORMAT,
  build_command = function()
    return { "cargo", "clippy", "--message-format=short" }
  end,
}

local TYPESCRIPT_CHECKER = {
  name = "tsc",
  root_markers = { "tsconfig.json" },
  error_format = "%f(%l\\,%c): %m",
  build_command = function(root)
    return { vim.fs.joinpath(root, "node_modules", ".bin", "tsc"), "--noEmit", "--pretty", "false", "-p", "." }
  end,
}

local PYTHON_CHECKER = {
  name = "ruff check",
  root_markers = { { "pyproject.toml", "ruff.toml", ".ruff.toml" }, { ".git" } },
  error_format = COLON_LOCATION_FORMAT,
  build_command = function()
    return { "ruff", "check", "--output-format=concise", "." }
  end,
}

local CHECKERS_BY_FILETYPE = {
  rust = CARGO_CHECKER,
  typescript = TYPESCRIPT_CHECKER,
  typescriptreact = TYPESCRIPT_CHECKER,
  python = PYTHON_CHECKER,
}

local is_running = false

local function build_error_format(checker)
  return table.concat({ DIRECTORY_ERROR_FORMAT, checker.error_format, IGNORE_OTHER_LINES_FORMAT }, ",")
end

-- Tools print paths relative to the project root; the directory line lets quickfix resolve them.
local function collect_output_lines(root, result)
  local output = (result.stdout or "") .. LINE_SEPARATOR .. (result.stderr or "")
  local lines = vim.split(output, LINE_SEPARATOR, { plain = true })
  table.insert(lines, 1, string.format(DIRECTORY_LINE_FORMAT, root))
  return lines
end

-- The directory line itself becomes an invalid quickfix entry; only real findings are kept.
local function keep_valid_items()
  local valid_items = vim.tbl_filter(function(item)
    return item.valid == VALID_ITEM
  end, vim.fn.getqflist())
  vim.fn.setqflist({}, "r", { items = valid_items })
end

local function publish_results(checker, root, result)
  is_running = false
  vim.fn.setqflist({}, " ", {
    title = QUICKFIX_TITLE_PREFIX .. checker.name,
    lines = collect_output_lines(root, result),
    efm = build_error_format(checker),
  })
  keep_valid_items()
  vim.notify(string.format("%s: %d problems", checker.name, #vim.fn.getqflist()), vim.log.levels.INFO)
  vim.cmd.copen()
end

local function warn(message)
  vim.notify(message, vim.log.levels.WARN)
end

local function run_checker(checker, root)
  local command = checker.build_command(root)
  if vim.fn.executable(command[1]) == 0 then
    warn("Project check: " .. command[1] .. " not found")
    return
  end
  is_running = true
  vim.notify("Checking project with " .. checker.name .. "…", vim.log.levels.INFO)
  vim.system(
    command,
    { cwd = root, text = true },
    vim.schedule_wrap(function(result)
      publish_results(checker, root, result)
    end)
  )
end

function M.check()
  if is_running then
    warn("Project check already running")
    return
  end
  local checker = CHECKERS_BY_FILETYPE[vim.bo.filetype]
  if not checker then
    warn("No project check for filetype '" .. vim.bo.filetype .. "'")
    return
  end
  local root = vim.fs.root(0, checker.root_markers)
  if not root then
    warn("Project check: no project root found for " .. checker.name)
    return
  end
  run_checker(checker, root)
end

vim.keymap.set("n", "<leader>D", M.check, { silent = true, desc = "Check whole project" })

return M
