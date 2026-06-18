vim.pack.add({ "https://github.com/folke/snacks.nvim" })
require("snacks").setup({
	-- -@type snacks.Config
	bigfile = { enabled = true },
	-- Disabled: dashboard-nvim + milli own the start screen. Two dashboards both
	-- render on VimEnter and conflict. Re-enable here only if you drop dashboard.lua.
	dashboard = { enabled = false },
	explorer = { enabled = false },
	indent = { enabled = true },
	input = { enabled = true },
	picker = { enabled = true },
	notifier = { enabled = true },
	quickfile = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = true },
	statuscolumn = { enabled = true },
	words = { enabled = true },
})
