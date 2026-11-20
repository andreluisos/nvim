local buffer_text = require("buffer_text")

local FORMATTER_TIMEOUT_MILLISECONDS = 5000
local BUFFER_PATH_PLACEHOLDER = "{buffer_path}"
local FORMATTING_METHOD = "textDocument/formatting"
local DEFAULT_SUCCESSFUL_EXIT_CODES = { 0 }
local LINT_FINDINGS_EXIT_CODES = { 0, 1 }

local PRETTIER = { command = { "prettier", "--stdin-filepath", BUFFER_PATH_PLACEHOLDER } }
local SQLFLUFF = {
  command = { "sqlfluff", "format", "--dialect=ansi", "-" },
  successful_exit_codes = LINT_FINDINGS_EXIT_CODES,
}

local FORMATTERS_BY_FILETYPE = {
  lua = {
    command = {
      "stylua",
      "--search-parent-directories",
      "--respect-ignores",
      "--stdin-filepath",
      BUFFER_PATH_PLACEHOLDER,
      "--",
      "-",
    },
  },
  python = { command = { "black", "--stdin-filename", BUFFER_PATH_PLACEHOLDER, "--quiet", "-" } },
  java = { command = { "google-java-format", "-" } },
  kotlin = { command = { "ktlint", "--format", "--stdin", "--log-level=none" } },
  sql = SQLFLUFF,
  mysql = SQLFLUFF,
  plsql = SQLFLUFF,
  css = PRETTIER,
  graphql = PRETTIER,
  handlebars = PRETTIER,
  html = PRETTIER,
  htmlangular = PRETTIER,
  javascript = PRETTIER,
  javascriptreact = PRETTIER,
  json = PRETTIER,
  jsonc = PRETTIER,
  less = PRETTIER,
  markdown = PRETTIER,
  ["markdown.mdx"] = PRETTIER,
  scss = PRETTIER,
  typescript = PRETTIER,
  typescriptreact = PRETTIER,
  vue = PRETTIER,
  yaml = PRETTIER,
}

local function resolve_formatter_command(command_template, buffer_path)
  return vim.tbl_map(function(argument)
    return argument == BUFFER_PATH_PLACEHOLDER and buffer_path or argument
  end, command_template)
end

local function run_formatter(formatter, buffer_path, input)
  local command = resolve_formatter_command(formatter.command, buffer_path)
  local result = vim.system(command, { stdin = input, text = true }):wait(FORMATTER_TIMEOUT_MILLISECONDS)
  local successful_exit_codes = formatter.successful_exit_codes or DEFAULT_SUCCESSFUL_EXIT_CODES
  if not vim.tbl_contains(successful_exit_codes, result.code) then
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

local function format_with_external_command(bufnr, formatter)
  local succeeded, output_or_error =
    pcall(run_formatter, formatter, vim.api.nvim_buf_get_name(bufnr), buffer_text.read(bufnr))
  if not succeeded then
    vim.notify("Formatting skipped: " .. output_or_error, vim.log.levels.WARN)
    return
  end
  replace_buffer_lines_if_changed(bufnr, buffer_text.split(output_or_error))
end

local function format_with_language_server(bufnr)
  if #vim.lsp.get_clients({ bufnr = bufnr, method = FORMATTING_METHOD }) > 0 then
    vim.lsp.buf.format({ bufnr = bufnr, async = false })
  end
end

local function format_buffer_before_write(event)
  local formatter = FORMATTERS_BY_FILETYPE[vim.bo[event.buf].filetype]
  if formatter then
    format_with_external_command(event.buf, formatter)
  else
    format_with_language_server(event.buf)
  end
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("format_on_save", { clear = true }),
  desc = "Format buffer before writing",
  callback = format_buffer_before_write,
})
