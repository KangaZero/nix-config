return {
	vim.pack.add({
		"https://github.com/stevearc/conform.nvim",
	}),
	require("conform").setup({
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff", lsp_format = "fallback" },
			-- Conform will run multiple formatters sequentially
			-- python = { "isort", "black" },
			-- You can customize some of the format options for the filetype (:help conform.format)
			rust = { "rustfmt", lsp_format = "fallback" },
			-- Conform will run the first available formatter
			javascript = { "biome", "prettier", stop_after_first = true },
			typescript = { "biome", "prettier", stop_after_first = true },
			json = { "biome", "prettier", stop_after_first = true },
			nix = { "nixfmt" },
		},
	}),
}
