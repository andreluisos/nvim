local JDTLS_CACHE_DIRECTORY = vim.fs.joinpath(vim.fn.stdpath("cache"), "jdtls")
local LOMBOK_JAR = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "share", "jdtls", "lombok.jar")
local JAVA_SETTINGS = {
  java = { inlayHints = { parameterNames = { enabled = "all" } } },
}

local function find_project_root(file_path)
  return vim.fs.root(file_path, vim.lsp.config.jdtls.root_markers)
end

-- Each project gets its own jdtls config and workspace so indexes never collide.
local function build_command(root_dir)
  local command = { vim.fn.exepath("jdtls"), "--jvm-arg=-javaagent:" .. LOMBOK_JAR }
  if not root_dir then
    return command
  end
  local project_cache = vim.fs.joinpath(JDTLS_CACHE_DIRECTORY, vim.fs.basename(root_dir))
  return vim.list_extend(command, {
    "-configuration",
    vim.fs.joinpath(project_cache, "config"),
    "-data",
    vim.fs.joinpath(project_cache, "workspace"),
  })
end

local function attach_jdtls(event)
  local root_dir = find_project_root(vim.api.nvim_buf_get_name(event.buf))
  require("jdtls").start_or_attach({
    cmd = build_command(root_dir),
    root_dir = root_dir,
    settings = JAVA_SETTINGS,
  })
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("java_jdtls", { clear = true }),
  pattern = "java",
  desc = "Start or attach jdtls",
  callback = attach_jdtls,
})
