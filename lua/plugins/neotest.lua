return {
    {
        "rcasia/neotest-java",
        ft = "java",
        dependencies = {
            "mfussenegger/nvim-jdtls",
            "mfussenegger/nvim-dap",           -- for the debugger
            "rcarriga/nvim-dap-ui",            -- recommended
            "theHamsta/nvim-dap-virtual-text", -- recommended
        },
        init = function()
            local keys = require("lazyvim.plugins.lsp.keymaps").get()
            keys[#keys + 1] = {
                "<leader>tt",
                function() require("neotest").run.run(vim.fn.expand("%")) end,
                mode = "n",
                desc =
                "Run test file"
            }
            keys[#keys + 1] = {
                "<leader>tr",
                function() require("neotest").run.run() end,
                mode = "n",
                desc =
                "Run nearest test"
            }
            keys[#keys + 1] = {
                "<leader>tD",
                function() require("neotest").run.run({ strategy = "dap" }) end,
                mode = "n",
                desc =
                "Debug test file"
            }
            keys[#keys + 1] = {
                "<leader>td",
                function()
                    require("neotest").run.run({
                        vim.fn.expand("%"),
                        strategy =
                        "dap"
                    })
                end,
                mode = "n",
                desc = "Debug nearest test"
            }
        end,
    },
    {
        "nvim-neotest/neotest",
        opts = {
            adapters = {
                ["neotest-java"] = {
                    -- config here
                },
            },
        },
    },
}
