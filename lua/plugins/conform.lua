return {
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			opts.ensure_installed = vim.tbl_extend(
				"force",
				opts.ensure_installed,
				{ "google-java-format", "prettier", "black", "clang-format" }
			)
		end,
	},
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters = {
				["google-java-format"] = {
					-- prepend_args = { "-a" },
				},
				["clang-format"] = {
					prepend_args = { "-style=Google", "--tab-width=4" },
				},
			},
			formatters_by_ft = {
				java = { "google-java-format" },
				python = { "black" },
				typescript = { "prettier" },
				javascript = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				json = { "prettier" },
			},
		},
	},
}
