local function get_screen_size()
	local uis = vim.api.nvim_list_uis()
	if #uis > 0 then
		return uis[1].width, uis[1].height
	else
		return nil, nil
	end
end

local screen_width, screen_height = get_screen_size()

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
			controls = {
				element = "repl",
				enabled = true,
				icons = {
					disconnect = "",
					pause = "",
					play = " (F5)",
					run_last = "",
					step_back = "",
					step_into = " (F8)",
					step_out = " (F7)",
					step_over = " (F9)",
					terminate = "",
				},
			},
			floating = { border = "single" },
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.40 },
						{ id = "breakpoints", size = 0.20 },
						{ id = "stacks", size = 0.20 },
						{ id = "watches", size = 0.20 },
						{ id = "repl", size = 0.01 },
					},
					position = "left",
					size = math.floor(screen_width * 0.31),
				},
				{
					elements = {
						{ id = "console", size = 1 },
					},
					position = "bottom",
					size = math.floor(screen_height * 0.40),
				},
			},
		},
		config = function(_, opts)
			local dap = require "dap"
			local dapui = require "dapui"
			dapui.setup(opts)
			dap.listeners.after.event_initialized["dapui_config"] = function()
				require("neo-tree.command").execute { action = "close" }
				dapui.open {}
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close {}
				require("neo-tree.command").execute { action = "show" }
			end
			-- dap.listeners.before.event_exited["dapui_config"] = function()
			-- 	dapui.close {}
			-- end
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		event = "InsertEnter",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = false,
			},
		},
	},
	{
		"saghen/blink.cmp",
		optional = true,
		dependencies = { "giuxtaposition/blink-cmp-copilot" },
		opts = {
			sources = {
				default = { "copilot" },
				providers = {
					copilot = {
						name = "copilot",
						module = "blink-cmp-copilot",
						kind = "Copilot",
						score_offset = 0,
						async = true,
					},
				},
			},
		},
	},
}
