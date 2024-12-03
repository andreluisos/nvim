return {
	"williamboman/mason.nvim",
	opts = {
		ensure_installed = {
			"stylua",
			"shellcheck",
			"shfmt",
			"flake8",
			"black",
			"clang-format",
			"google-java-format",
			"java-debug-adapter",
			"java-test",
			"jdtls",
			"js-debug-adapter",
		},
	},
}
