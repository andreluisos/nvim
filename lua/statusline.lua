local M = {}

local system_status = require("system_status")

local MODE_HIGHLIGHT = "StlMode"
local GIT_BRANCH_HIGHLIGHT = "StlGit"
local MODE_FOREGROUND = "#deddda"
local MODE_BACKGROUND = "#193d66"
local GIT_BRANCH_FOREGROUND = "#ffffff"
local GIT_BRANCH_BACKGROUND = "#4a4a4d"
local GIT_TIMEOUT_MILLISECONDS = 1000
local PATH_SEPARATOR_LENGTH = 1
local SEGMENT_SEPARATOR = " | "
local CLOCK_FORMAT = "%d/%m/%Y %H:%M:%S"
local CLOCK_REDRAW_INTERVAL_MILLISECONDS = 1000
local START_IMMEDIATELY = 0
local SERVER_NAME_SEPARATOR = ","

local MODE_LABELS = {
  n = "NORMAL",
  i = "INSERT",
  v = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  c = "COMMAND",
  t = "TERMINAL",
  R = "REPLACE",
  s = "SELECT",
  S = "S-LINE",
  ["\19"] = "S-BLOCK",
}

local DIAGNOSTIC_SEGMENTS = {
  { severity = vim.diagnostic.severity.ERROR, icon = "\u{ea87} ", highlight = "DiagnosticError" },
  { severity = vim.diagnostic.severity.WARN, icon = "\u{ea6c} ", highlight = "DiagnosticWarn" },
  { severity = vim.diagnostic.severity.INFO, icon = "\u{ea74} ", highlight = "DiagnosticInfo" },
  { severity = vim.diagnostic.severity.HINT, icon = "\u{ea61} ", highlight = "DiagnosticHint" },
}

local function define_highlights()
  vim.api.nvim_set_hl(0, MODE_HIGHLIGHT, { fg = MODE_FOREGROUND, bg = MODE_BACKGROUND })
  vim.api.nvim_set_hl(0, GIT_BRANCH_HIGHLIGHT, { fg = GIT_BRANCH_FOREGROUND, bg = GIT_BRANCH_BACKGROUND })
end

local function highlighted(highlight, text)
  return "%#" .. highlight .. "#" .. text .. "%*"
end

local function escape_statusline_text(text)
  return (text:gsub("%%", "%%%%"))
end

local function render_mode()
  local mode = vim.fn.mode()
  return highlighted(MODE_HIGHLIGHT, " " .. (MODE_LABELS[mode] or mode:upper()) .. " ")
end

local function render_git_branch()
  if not vim.b.git_branch then
    return ""
  end
  return highlighted(GIT_BRANCH_HIGHLIGHT, " " .. escape_statusline_text(vim.b.git_branch) .. " ")
end

local function render_path()
  if not vim.b.rel_path then
    return "%f"
  end
  return escape_statusline_text(vim.b.rel_path)
end

local function render_diagnostics()
  local counts = vim.diagnostic.count(0)
  local segments = {}
  for _, segment in ipairs(DIAGNOSTIC_SEGMENTS) do
    local count = counts[segment.severity]
    if count and count > 0 then
      table.insert(segments, highlighted(segment.highlight, segment.icon .. count) .. " ")
    end
  end
  return table.concat(segments)
end

local function render_language_servers()
  local names = vim.tbl_map(function(client)
    return client.name
  end, vim.lsp.get_clients({ bufnr = 0 }))
  if #names == 0 then
    return ""
  end
  return " " .. escape_statusline_text(table.concat(names, SERVER_NAME_SEPARATOR))
end

local function render_system_status()
  local text = system_status.text()
  if text == "" then
    return ""
  end
  return SEGMENT_SEPARATOR .. escape_statusline_text(text)
end

local function render_clock()
  return SEGMENT_SEPARATOR .. os.date(CLOCK_FORMAT)
end

function M.render()
  return render_mode()
    .. render_git_branch()
    .. " "
    .. render_path()
    .. "%="
    .. render_diagnostics()
    .. vim.bo.filetype
    .. render_language_servers()
    .. " %l:%c"
    .. render_system_status()
    .. render_clock()
end

local function read_git_output(arguments)
  local result = vim.system(vim.list_extend({ "git" }, arguments), { text = true }):wait(GIT_TIMEOUT_MILLISECONDS)
  if result.code ~= 0 then
    return ""
  end
  return vim.trim(result.stdout)
end

local function update_buffer_git_context()
  local repository_root = read_git_output({ "rev-parse", "--show-toplevel" })
  if repository_root == "" then
    vim.b.git_branch = nil
    vim.b.rel_path = vim.fn.expand("%:p:~")
    return
  end
  vim.b.git_branch = read_git_output({ "branch", "--show-current" })
  vim.b.rel_path = vim.fn.expand("%:p"):sub(#repository_root + PATH_SEPARATOR_LENGTH + 1)
end

local function redraw_statusline()
  vim.cmd.redrawstatus({ bang = true })
end

local function start_clock_timer()
  local timer = assert(vim.uv.new_timer())
  timer:start(START_IMMEDIATELY, CLOCK_REDRAW_INTERVAL_MILLISECONDS, vim.schedule_wrap(redraw_statusline))
end

local statusline_group = vim.api.nvim_create_augroup("native_statusline", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", { group = statusline_group, callback = update_buffer_git_context })
vim.api.nvim_create_autocmd("DiagnosticChanged", { group = statusline_group, callback = redraw_statusline })
vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, { group = statusline_group, callback = redraw_statusline })

define_highlights()
start_clock_timer()
vim.o.statusline = "%!v:lua.require'statusline'.render()"

return M
