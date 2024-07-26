return {
    { "nvimdev/dashboard-nvim",   enabled = false },
    { "folke/noice.nvim",         enabled = false },
    { "folke/flash.nvim",         enabled = false },
    { "echasnovski/mini.comment", enabled = false },
    {
        "hrsh7th/nvim-cmp",
        opts = function(_, opts)
            local cmp = require("cmp")
            opts.mapping = vim.tbl_deep_extend("force", opts.mapping, {
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
                -- put here the keymaps that you want to change
            })
        end,
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = "mason.nvim",
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
            -- Makes a best effort to setup the various debuggers with
            -- reasonable debug configurations
            automatic_installation = true,

            -- You can provide additional configuration to the handlers,
            -- see mason-nvim-dap README for more information
            handlers = {},

            -- You'll need to check that you have the required things installed
            -- online, please don't ask me how to install them :)
            ensure_installed = {
                "javadbg",
                "javatest",
                -- Update this to ensure that you have the debuggers for the langs you want
            },
        },
        -- mason-nvim-dap is loaded when nvim-dap loads
        config = function() end,
    },
}
