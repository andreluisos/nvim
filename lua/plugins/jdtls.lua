return {
  "mfussenegger/nvim-jdtls",
  opts = function(_, opts)
    -- 1. ROBUSTLY LIMIT THE MAIN JDTLS SERVER
    -- The default nvim-jdtls cmd includes "-Xmx1G".
    -- This code finds and replaces it, or adds it if not found.
    local cmd = opts.cmd
    local new_xmx = "-Xmx512m" -- Your desired limit for the main server
    local new_xms = "-Xms128m"
    local xmx_found, xms_found = false, false

    for i, arg in ipairs(cmd) do
      if arg:find("^-Xmx") then
        cmd[i] = new_xmx
        xmx_found = true
      elseif arg:find("^-Xms") then
        cmd[i] = new_xms
        xms_found = true
      end
    end
    if not xmx_found then
      table.insert(cmd, new_xmx)
    end
    if not xms_found then
      table.insert(cmd, new_xms)
    end

    -- 2. THE CRITICAL FIX: LIMIT THE BUILD TOOLS
    -- This tells jdtls what memory limits to use when it spawns
    -- Gradle or Maven to import the project. 1GB is a reasonable
    -- limit for a build tool.
    opts.settings = opts.settings or {}
    vim.tbl_deep_extend("force", opts.settings, {
      java = {
        import = {
          -- For Gradle projects
          gradle = {
            jvm = { arguments = "-Xms128m -Xmx1g" },
          },
          -- For Maven projects
          maven = {
            jvm = { arguments = "-Xms128m -Xmx1g" },
          },
        },
      },
    })
  end,
}
-- return {
--   "mfussenegger/nvim-jdtls",
--   opts = function(_, opts)
--     table.insert(opts.cmd, "-Xms128m")
--     table.insert(opts.cmd, "-Xmx512m")
--   end,
-- }
