local buffer_text = require("buffer_text")

local LINT_EVENTS = { "FileType", "BufWritePost", "InsertLeave" }
local ONE_BASED_OFFSET = 1
local severity = vim.diagnostic.severity
local lint_namespace = vim.api.nvim_create_namespace("native_lint")

local HADOLINT_SEVERITIES = {
  error = severity.ERROR,
  warning = severity.WARN,
  info = severity.INFO,
  style = severity.HINT,
}

local function to_diagnostic(source, line, column, message, code, diagnostic_severity)
  return {
    lnum = line - ONE_BASED_OFFSET,
    col = column - ONE_BASED_OFFSET,
    message = message,
    code = code,
    severity = diagnostic_severity,
    source = source,
  }
end

local function parse_hadolint(output)
  return vim.tbl_map(function(finding)
    local finding_severity = HADOLINT_SEVERITIES[finding.level] or severity.WARN
    return to_diagnostic("hadolint", finding.line, finding.column, finding.message, finding.code, finding_severity)
  end, vim.json.decode(output))
end

local function parse_sqlfluff(output)
  local diagnostics = {}
  for _, file in ipairs(vim.json.decode(output)) do
    for _, violation in ipairs(file.violations) do
      local violation_severity = violation.warning and severity.WARN or severity.ERROR
      table.insert(
        diagnostics,
        to_diagnostic(
          "sqlfluff",
          violation.start_line_no,
          violation.start_line_pos,
          violation.description,
          violation.code,
          violation_severity
        )
      )
    end
  end
  return diagnostics
end

local function parse_ktlint(output)
  local diagnostics = {}
  for _, file in ipairs(vim.json.decode(output)) do
    for _, finding in ipairs(file.errors) do
      table.insert(
        diagnostics,
        to_diagnostic("ktlint", finding.line, finding.column, finding.message, finding.rule, severity.WARN)
      )
    end
  end
  return diagnostics
end

local SQLFLUFF = {
  command = { "sqlfluff", "lint", "--format", "json", "--dialect", "ansi", "-" },
  output_stream = "stdout",
  parse = parse_sqlfluff,
}

local LINTERS_BY_FILETYPE = {
  dockerfile = {
    command = { "hadolint", "--no-fail", "-f", "json", "-" },
    output_stream = "stdout",
    parse = parse_hadolint,
  },
  sql = SQLFLUFF,
  mysql = SQLFLUFF,
  plsql = SQLFLUFF,
  -- ktlint writes its report to stderr when reading stdin.
  kotlin = {
    command = { "ktlint", "--reporter=json", "--stdin" },
    output_stream = "stderr",
    parse = parse_ktlint,
  },
}

-- Compares text, not changedtick: startup option changes bump changedtick without editing the buffer.
local function is_stale(bufnr, linted_text)
  return not vim.api.nvim_buf_is_valid(bufnr) or buffer_text.read(bufnr) ~= linted_text
end

local function publish_diagnostics(bufnr, linted_text, linter, result)
  if is_stale(bufnr, linted_text) then
    return
  end
  local succeeded, diagnostics = pcall(linter.parse, result[linter.output_stream])
  if not succeeded then
    vim.notify("Lint output unreadable from " .. linter.command[1] .. ": " .. diagnostics, vim.log.levels.WARN)
    return
  end
  vim.diagnostic.set(lint_namespace, bufnr, diagnostics)
end

local function lint_buffer(event)
  local bufnr = event.buf
  local linter = LINTERS_BY_FILETYPE[vim.bo[bufnr].filetype]
  if not linter then
    return
  end
  local linted_text = buffer_text.read(bufnr)
  local on_exit = vim.schedule_wrap(function(result)
    publish_diagnostics(bufnr, linted_text, linter, result)
  end)
  local started, error_message = pcall(vim.system, linter.command, { stdin = linted_text, text = true }, on_exit)
  if not started then
    vim.notify("Lint skipped: " .. error_message, vim.log.levels.WARN)
  end
end

vim.api.nvim_create_autocmd(LINT_EVENTS, {
  group = vim.api.nvim_create_augroup("native_lint", { clear = true }),
  desc = "Lint buffer with external linters",
  callback = lint_buffer,
})
