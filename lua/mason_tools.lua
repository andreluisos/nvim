local REQUIRED_PACKAGES = {
  "lua-language-server",
  "vtsls",
  "vue-language-server",
  "angular-language-server",
  "tailwindcss-language-server",
  "json-lsp",
  "yaml-language-server",
  "taplo",
  "dockerfile-language-server",
  "docker-compose-language-service",
  "pyright",
  "ruff",
  "jdtls",
  "kotlin-language-server",
  "rust-analyzer",
  "clangd",
  "stylua",
  "prettier",
  "black",
  "google-java-format",
  "ktlint",
  "sqlfluff",
  "hadolint",
}

local function notify_later(message, level)
  vim.schedule(function()
    vim.notify(message, level)
  end)
end

local function report_install_result(package_name)
  return function(succeeded, result)
    if succeeded then
      notify_later("Mason installed " .. package_name, vim.log.levels.INFO)
    else
      notify_later("Mason failed to install " .. package_name .. ": " .. tostring(result), vim.log.levels.ERROR)
    end
  end
end

local function install_if_missing(registry, package_name)
  local package = registry.get_package(package_name)
  if package:is_installed() or package:is_installing() then
    return
  end
  notify_later("Mason installing " .. package_name, vim.log.levels.INFO)
  package:install({}, report_install_result(package_name))
end

local function install_missing_packages(registry)
  for _, package_name in ipairs(REQUIRED_PACKAGES) do
    local succeeded, error_message = pcall(install_if_missing, registry, package_name)
    if not succeeded then
      notify_later("Mason cannot install " .. package_name .. ": " .. error_message, vim.log.levels.ERROR)
    end
  end
end

local function ensure_required_packages()
  local registry = require("mason-registry")
  registry.refresh(function(succeeded)
    if not succeeded then
      notify_later("Mason registry refresh failed", vim.log.levels.ERROR)
      return
    end
    install_missing_packages(registry)
  end)
end

require("mason").setup()
ensure_required_packages()
