return {
	vim.pack.add({
		"https://github.com/mikavilpas/yazi.nvim",
		"https://github.com/nvim-lua/plenary.nvim",
	}),

	-- -@type YaziConfig | {}
	require("yazi").setup({
		version = "*", -- use the latest stable version
		event = "VeryLazy",
		-- dependencies = {
		-- 	{ "nvim-lua/plenary.nvim", lazy = true },
		-- },
		keys = {
			{
				"<c-up>",
				"<cmd>Yazi toggle<cr>",
				desc = "Resume the last yazi session",
			},
		},
		opts = {
			-- if you want to open yazi instead of netrw, see below for more info
			open_for_directories = false,
			keymaps = {
				show_help = "<f1>",
			},
		},
		init = function()
			-- mark netrw as loaded so it's not loaded at all.
			--
			-- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
			vim.g.loaded_netrwPlugin = 1

			vim.cmd("let g:netrw_banner = 0")
		end,
	}),
}
