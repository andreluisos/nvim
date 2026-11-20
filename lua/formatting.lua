local FORMATTER_TIMEOUT_MILLISECONDS = 5000
local BUFFER_PATH_PLACEHOLDER = "{buffer_path}"
local LINE_SEPARATOR = "\n"
local FORMATTING_METHOD = "textDocument/formatting"
local PRETTIER_COMMAND = { "prettier", "--stdin-filepath", BUFFER_PATH_PLACEHOLDER }

local FORMATTER_COMMANDS_BY_FILETYPE = {
  lua = { "stylua", "-" },
  javascript = PRETTIER_COMMAND,
  typescript = PRETTIER_COMMAND,
  typescriptreact = PRETTIER_COMMAND,
  json = PRETTIER_COMMAND,
}

local function resolve_formatter_command(command_template, buffer_path)
  return vim.tbl_map(function(argument)
    return argument == BUFFER_PATH_PLACEHOLDER and buffer_path or argument
  end, command_template)
end

local function read_buffer_text(bufnr)
  return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), LINE_SEPARATOR) .. LINE_SEPARATOR
end

local function split_formatter_output(output)
  local lines = vim.split(output, LINE_SEPARATOR, { plain = true })
  if lines[#lines] == "" then
    table.remove(lines)
  end
  return lines
end

local function run_formatter(command, input)
  local result = vim.system(command, { stdin = input, text = true }):wait(FORMATTER_TIMEOUT_MILLISECONDS)
  if result.code ~= 0 then
    error(string.format("%s exited with code %d: %s", command[1], result.code, result.stderr or ""), 0)
  end
  return result.stdout
end

local function replace_buffer_lines_if_changed(bufnr, formatted_lines)
  if vim.deep_equal(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), formatted_lines) then
    return
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_lines)
end

local function format_with_external_command(bufnr, command_template)
  local command = resolve_formatter_command(command_template, vim.api.nvim_buf_get_name(bufnr))
  local succeeded, output_or_error = pcall(run_formatter, command, read_buffer_text(bufnr))
  if not succeeded then
    vim.notify("Formatting skipped: " .. output_or_error, vim.log.levels.WARN)
    return
  end
  replace_buffer_lines_if_changed(bufnr, split_formatter_output(output_or_error))
end

local function format_with_language_server(bufnr)
  if #vim.lsp.get_clients({ bufnr = bufnr, method = FORMATTING_METHOD }) > 0 then
    vim.lsp.buf.format({ bufnr = bufnr, async = false })
  end
end

local function format_buffer_before_write(event)
  local command_template = FORMATTER_COMMANDS_BY_FILETYPE[vim.bo[event.buf].filetype]
  if command_template then
    format_with_external_command(event.buf, command_template)
  else
    format_with_language_server(event.buf)
  end
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("format_on_save", { clear = true }),
  desc = "Format buffer before writing",
  callback = format_buffer_before_write,
})
