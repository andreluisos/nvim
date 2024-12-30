return {
	{ "nvimdev/dashboard-nvim", enabled = false },
	{ "folke/noice.nvim", opts = {
		lsp = {
			progress = { enabled = false },
		},
	} },
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "nvim-neotest/nvim-nio" },
		keys = {
			{
				"<leader>du",
				function()
					require("dapui").toggle {}
				end,
				desc = "Dap UI",
			},
			{
				"<leader>de",
				function()
					require("dapui").eval()
				end,
				desc = "Eval",
				mode = { "n", "v" },
			},
		},
		opts = {
			floating = { border = "single" },
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.40 },
						{ id = "breakpoints", size = 0.20 },
						{ id = "stacks", size = 0.20 },
						{ id = "watches", size = 0.20 },
					},
					position = "left",
					size = 50,
				},
				{
					elements = {
						{ id = "console", size = 1 },
					},
					position = "bottom",
					size = 20,
				},
			},
		},
		config = function(_, opts)
			local dap = require "dap"
			local dapui = require "dapui"
			dapui.setup(opts)
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open {}
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close {}
			end
			-- dap.listeners.before.event_exited["dapui_config"] = function()
			-- 	dapui.close {}
			-- end
		end,
	},
}
