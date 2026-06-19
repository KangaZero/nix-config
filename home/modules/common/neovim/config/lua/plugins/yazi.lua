vim.pack.add({
	"https://github.com/mikavilpas/yazi.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
})

---@type YaziConfig
local opts = {
	open_for_directories = false,
	keymaps = {
		show_help = "<f1>",
	},
}
require("yazi").setup(opts)

-- Disable netrw so yazi is the only file manager. Done here directly because
-- this is a plain require (the old lazy.nvim `init` field was never called by
-- yazi.setup, so netrw was never actually disabled).
-- See https://github.com/mikavilpas/yazi.nvim/issues/802
vim.g.loaded_netrwPlugin = 1
vim.g.netrw_banner = 0
