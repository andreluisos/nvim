local treesitter = require("nvim-treesitter")

local PARSERS = {
  "bash",
  "c",
  "cpp",
  "css",
  "diff",
  "dockerfile",
  "html",
  "java",
  "javascript",
  "jsdoc",
  "json",
  "kotlin",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "rust",
  "scss",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "vue",
  "xml",
  "yaml",
}
local INDENT_EXPRESSION = "v:lua.require'nvim-treesitter'.indentexpr()"
local FOLD_EXPRESSION = "v:lua.vim.treesitter.foldexpr()"
local FOLD_METHOD = "expr"
local OPEN_ALL_FOLDS_LEVEL = 99

local function has_parser(language)
  return vim.treesitter.language.add(language) == true
end

local function has_query(language, query_name)
  return vim.treesitter.query.get(language, query_name) ~= nil
end

local function enable_folds()
  vim.wo[0][0].foldmethod = FOLD_METHOD
  vim.wo[0][0].foldexpr = FOLD_EXPRESSION
end

local function enable_treesitter(event)
  local language = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
  if not language or not has_parser(language) then
    return
  end
  vim.treesitter.start(event.buf, language)
  if has_query(language, "folds") then
    enable_folds()
  end
  if has_query(language, "indents") then
    vim.bo[event.buf].indentexpr = INDENT_EXPRESSION
  end
end

vim.o.foldlevel = OPEN_ALL_FOLDS_LEVEL
treesitter.install(PARSERS)

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter_features", { clear = true }),
  desc = "Start treesitter highlighting, folds and indent when a parser exists",
  callback = enable_treesitter,
})
