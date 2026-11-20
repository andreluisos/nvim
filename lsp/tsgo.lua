local SERVER_EXECUTABLE = "tsgo"
local LOCKFILE_MARKERS = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
local REPOSITORY_MARKERS = { ".git" }
local DENO_CONFIG_MARKERS = { "deno.json", "deno.jsonc" }
local DENO_LOCK_MARKERS = { "deno.lock" }

local function resolve_server_executable(root_dir)
  if root_dir then
    local project_executable = vim.fs.joinpath(root_dir, "node_modules", ".bin", SERVER_EXECUTABLE)
    if vim.fn.executable(project_executable) == 1 then
      return project_executable
    end
  end
  return SERVER_EXECUTABLE
end

local function is_deeper_than(candidate_root, project_root)
  return candidate_root ~= nil and (project_root == nil or #candidate_root > #project_root)
end

-- A Deno module nested in a Node monorepo must be left to denols: the nearest deno.lock or
-- deno.json wins over the nearest package-manager lockfile.
local function belongs_to_deno(bufnr, project_root)
  local deno_lock_root = vim.fs.root(bufnr, DENO_LOCK_MARKERS)
  local deno_config_root = vim.fs.root(bufnr, DENO_CONFIG_MARKERS)
  return is_deeper_than(deno_lock_root, project_root)
    or (deno_config_root ~= nil and (project_root == nil or #deno_config_root >= #project_root))
end

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local executable = resolve_server_executable((config or {}).root_dir)
    return vim.lsp.rpc.start({ executable, "--lsp", "--stdio" }, dispatchers)
  end,
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_dir = function(bufnr, on_dir)
    local project_root = vim.fs.root(bufnr, { LOCKFILE_MARKERS, REPOSITORY_MARKERS })
    if belongs_to_deno(bufnr, project_root) then
      return
    end
    on_dir(project_root or vim.fn.getcwd())
  end,
  settings = {
    typescript = {
      inlayHints = {
        parameterNames = { enabled = "literals", suppressWhenArgumentMatchesName = true },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
    },
  },
}
