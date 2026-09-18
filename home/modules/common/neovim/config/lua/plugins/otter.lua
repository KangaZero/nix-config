vim.pack.add({
	"https://github.com/jmbuhr/otter.nvim",
})

require("otter").setup({
	-- Nix indents its embedded code, and otter maps otter-buffer positions back to
	-- the host buffer by column. Left false, every diagnostic and completion in an
	-- indented `''...''` block lands at the wrong column.
	handle_leading_whitespace = true,

	lsp = {
		diagnostic_update_event = { "BufWritePost", "InsertLeave" },
	},

	buffers = {
		-- Otter buffers stay in memory; nothing writes `<path>.otter.lua` next to the
		-- real file. Only needed by linters that demand a file on disk.
		write_to_disk = false,
	},
})

-- Attach on Nix buffers. nvim-treesitter's nix `injections.scm` turns a comment
-- immediately preceding a string into a language injection, so
--
--   setup = # lua
--     ''
--       require("foo").setup({})
--     '';
--
-- becomes a real Lua region that otter can hand to lua_ls. The same query injects
-- bash for derivation phases (`buildPhase`, `preFixup`, `script`, writeShellScript),
-- which is what makes this useful in a nixpkgs checkout too.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "nix",
	desc = "otter: LSP for Lua/bash embedded in Nix strings",
	callback = function()
		require("otter").activate({ "lua", "bash" })
	end,
})
