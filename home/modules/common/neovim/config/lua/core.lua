--3rd party packs
vim.pack.add({
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason-lspconfig.nvim",
	"https://github.com/brenoprata10/nvim-highlight-colors",
	"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
})

require("nvim-highlight-colors").setup({
	render = "background", -- switch to 'virtual' to allow for 'virtual symbol'
	-- virtual_symbol = "⚫︎",
	enable_named_colors = true,
	enable_tailwind = true,
	exclude_filetypes = { "mason", "help" },
	-- virtual_symbol_suffix = "",
})

require("nvim-treesitter-textobjects").setup({
	select = {
		-- Automatically jump forward to textobj, similar to targets.vim
		lookahead = true,
		-- You can choose the select mode (default is charwise 'v')

		selection_modes = {
			["@parameter.outer"] = "v", -- charwise
			["@function.outer"] = "V", -- linewise
			["@class.outer"] = "<c-v>", -- blockwise
		},
		include_surrounding_whitespace = false,
	},
	move = {
		-- whether to set jumps in the jumplist
		set_jumps = true,
	},
})

--Built-in packs
vim.cmd.packadd("cfilter")
vim.cmd.packadd("nvim.undotree")
vim.cmd.packadd("nvim.difftool")
