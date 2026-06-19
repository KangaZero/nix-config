vim.pack.add({ "https://github.com/folke/snacks.nvim" })

---@type snacks.Config
local opts = {
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
}
require("snacks").setup(opts)
