local M = {}

local LINE_SEPARATOR = "\n"

function M.read(bufnr)
  return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), LINE_SEPARATOR) .. LINE_SEPARATOR
end

function M.split(text)
  local lines = vim.split(text, LINE_SEPARATOR, { plain = true })
  if lines[#lines] == "" then
    table.remove(lines)
  end
  return lines
end

return M
