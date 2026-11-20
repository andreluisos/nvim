local M = {}

local STATUS_SCRIPT = vim.fs.joinpath(vim.env.HOME, ".config", "tmux", "status.sh")
local REFRESH_INTERVAL_MILLISECONDS = 5000
local START_IMMEDIATELY = 0
local SUCCESS_EXIT_CODE = 0

local status_text = ""
local is_refreshing = false

local function store_result(result)
  is_refreshing = false
  if result.code == SUCCESS_EXIT_CODE then
    status_text = vim.trim(result.stdout or "")
    vim.cmd.redrawstatus({ bang = true })
  end
end

local function refresh()
  if is_refreshing then
    return
  end
  is_refreshing = true
  vim.system({ STATUS_SCRIPT }, { text = true }, vim.schedule_wrap(store_result))
end

local function start_refresh_timer()
  local timer = assert(vim.uv.new_timer())
  timer:start(START_IMMEDIATELY, REFRESH_INTERVAL_MILLISECONDS, vim.schedule_wrap(refresh))
end

function M.text()
  return status_text
end

if vim.fn.executable(STATUS_SCRIPT) == 1 then
  start_refresh_timer()
end

return M
