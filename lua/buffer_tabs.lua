local M = {}

local statusline = require("statusline")

local CURRENT_HIGHLIGHT = "TabLineSel"
local OTHER_HIGHLIGHT = "TabLine"
local FILL_HIGHLIGHT = "TabLineFill"
local HIGHLIGHT_FORMAT = "%%#%s#"
local LABEL_FORMAT = " %s%s "
local MODIFIED_MARK = " ●"
local NO_NAME_LABEL = "[No Name]"
local FILE_BUFFER_TYPE = ""
local LISTED = 1
local ALWAYS_SHOW_TABLINE = 2

local function is_file_buffer(buffer)
  return vim.bo[buffer].buftype == FILE_BUFFER_TYPE
end

local function file_buffers()
  local buffers = vim.tbl_map(function(info)
    return info.bufnr
  end, vim.fn.getbufinfo({ buflisted = LISTED }))
  return vim.tbl_filter(is_file_buffer, buffers)
end

local function buffer_label(buffer)
  local name = vim.api.nvim_buf_get_name(buffer)
  local label = name == "" and NO_NAME_LABEL or vim.fn.fnamemodify(name, ":t")
  local mark = vim.bo[buffer].modified and MODIFIED_MARK or ""
  return string.format(LABEL_FORMAT, statusline.escape_statusline_text(label), mark)
end

local function render_buffer(buffer, current)
  local highlight = buffer == current and CURRENT_HIGHLIGHT or OTHER_HIGHLIGHT
  return string.format(HIGHLIGHT_FORMAT, highlight) .. buffer_label(buffer)
end

function M.render()
  local current = vim.api.nvim_get_current_buf()
  local rendered = vim.tbl_map(function(buffer)
    return render_buffer(buffer, current)
  end, file_buffers())
  return table.concat(rendered) .. string.format(HIGHLIGHT_FORMAT, FILL_HIGHLIGHT)
end

vim.o.showtabline = ALWAYS_SHOW_TABLINE
vim.o.tabline = "%!v:lua.require'buffer_tabs'.render()"

return M
