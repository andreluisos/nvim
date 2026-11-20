local MASON_PACKAGES_DIRECTORY = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages")
local VUE_PLUGIN_LOCATION =
  vim.fs.joinpath(MASON_PACKAGES_DIRECTORY, "vue-language-server", "node_modules", "@vue", "language-server")
local ANGULAR_PLUGIN_LOCATION =
  vim.fs.joinpath(MASON_PACKAGES_DIRECTORY, "angular-language-server", "node_modules", "@angular", "language-server")
local MOVE_TO_FILE_COMMAND = "_typescript.moveToFileRefactoring"
local NEW_PATH_CHOICE = "Enter new path..."
local MAX_INLAY_HINT_LENGTH = 30
local LSP_TO_TSSERVER_OFFSET = 1

local LANGUAGE_SETTINGS = {
  updateImportsOnFileMove = { enabled = "always" },
  suggest = { completeFunctionCalls = true },
  inlayHints = {
    enumMemberValues = { enabled = true },
    functionLikeReturnTypes = { enabled = true },
    parameterNames = { enabled = "literals" },
    parameterTypes = { enabled = true },
    propertyDeclarationTypes = { enabled = true },
    variableTypes = { enabled = false },
  },
}

local function to_tsserver_range(file, range)
  return {
    file = file,
    startLine = range.start.line + LSP_TO_TSSERVER_OFFSET,
    startOffset = range.start.character + LSP_TO_TSSERVER_OFFSET,
    endLine = range["end"].line + LSP_TO_TSSERVER_OFFSET,
    endOffset = range["end"].character + LSP_TO_TSSERVER_OFFSET,
  }
end

local function request_move(client, command, destination)
  local action, uri, range = unpack(command.arguments)
  client:request("workspace/executeCommand", {
    command = command.command,
    arguments = { action, uri, range, destination },
  })
end

local function prompt_for_new_destination(source_file, on_destination)
  vim.ui.input({
    prompt = "Enter move destination:",
    default = vim.fn.fnamemodify(source_file, ":h") .. "/",
    completion = "file",
  }, function(destination)
    if destination then
      on_destination(destination)
    end
  end)
end

local function format_destination(destination)
  if destination == NEW_PATH_CHOICE then
    return destination
  end
  return vim.fn.fnamemodify(destination, ":~:.")
end

local function choose_destination(source_file, suggested_files, on_destination)
  local choices = vim.list_extend({ NEW_PATH_CHOICE }, suggested_files)
  vim.ui.select(choices, { prompt = "Select move destination:", format_item = format_destination }, function(choice)
    if choice == NEW_PATH_CHOICE then
      prompt_for_new_destination(source_file, on_destination)
    elseif choice then
      on_destination(choice)
    end
  end)
end

-- vtsls offers "Move to file" but expects the client to pick the destination.
local function move_to_file(command, context)
  local client = assert(vim.lsp.get_client_by_id(context.client_id))
  local _, uri, range = unpack(command.arguments)
  local source_file = vim.uri_to_fname(uri)
  client:request("workspace/executeCommand", {
    command = "typescript.tsserverRequest",
    arguments = { "getMoveToRefactoringFileSuggestions", to_tsserver_range(source_file, range) },
  }, function(error, result)
    if error then
      vim.notify("Move to file failed: " .. error.message, vim.log.levels.ERROR)
      return
    end
    choose_destination(source_file, result.body.files, function(destination)
      request_move(client, command, destination)
    end)
  end)
end

return {
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
  },
  commands = { [MOVE_TO_FILE_COMMAND] = move_to_file },
  settings = {
    complete_function_calls = true,
    vtsls = {
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = {
        maxInlayHintLength = MAX_INLAY_HINT_LENGTH,
        completion = { enableServerSideFuzzyMatch = true },
      },
      tsserver = {
        globalPlugins = {
          {
            name = "@vue/typescript-plugin",
            location = VUE_PLUGIN_LOCATION,
            languages = { "vue" },
            configNamespace = "typescript",
            enableForWorkspaceTypeScriptVersions = true,
          },
          {
            name = "@angular/language-server",
            location = ANGULAR_PLUGIN_LOCATION,
            enableForWorkspaceTypeScriptVersions = false,
          },
        },
      },
    },
    typescript = LANGUAGE_SETTINGS,
    javascript = vim.deepcopy(LANGUAGE_SETTINGS),
  },
}
