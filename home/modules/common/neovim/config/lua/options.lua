vim.o.mouse = ""
vim.o.undofile = true -- undo/redo even after closing file
vim.o.timeoutlen = 300 -- Decrease mapped sequence wait time
vim.o.updatetime = 250 -- Decrease update time
vim.o.number = true -- show line numbers
vim.o.relativenumber = true -- relative numbers (easier j/k jumps)
vim.o.cursorline = true -- highlight the current line
vim.o.wrap = true -- wrap long lines
vim.o.confirm = true -- ask to save instead of erroring on :q
vim.o.ignorecase = true -- case-insensitive search...
vim.o.smartcase = true -- ...unless you type a capital
vim.o.termguicolors = true -- true color support
-- vim.schedule(function()
-- 	vim.o.clipboard = "unnamedplus"
-- 	if vim.fn.has("wsl") then
-- 		vim.g.clipboard = {
-- 			name = "win32yank-wsl",
-- 			copy = {
-- 				["+"] = "win32yank.exe -i --crlf",
-- 				["*"] = "win32yank.exe -i --crlf",
-- 			},
-- 			paste = {
-- 				["+"] = "win32yank.exe -o --crlf",
-- 				["*"] = "win32yank.exe -o --crlf",
-- 			},
-- 			cache_enable = 0,
-- 		}
-- 	end
-- end) -- to increase startime a bit
-- vim.o.clipboard = "unnamedplus" -- use system clipboard
vim.o.signcolumn = "yes" -- always show the sign column (gitsigns)
-- NOTE: "debug" writes huge volumes to the LSP log (disk + slowdown). Use
-- "warn" normally; bump to "debug" only when actively debugging a server.
vim.lsp.log.set_level("warn")
-- vim.opt.colorcolumn = '80'
-- vim.opt.textwidth = 80
-- vim.o.autocomplete = true --completeopt defined at autocmds.lua on LspAttach
-- vim.opt.swapfile = false
-- vim.opt.linebreak = true
-- vim.opt.termguicolors = true
-- vim.opt.wildoptions:append({ "fuzzy" })
-- vim.opt.path:append({ "**" })

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-guide-options`
vim.o.list = false
-- vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.o.inccommand = "split"

vim.o.smoothscroll = true
-- function BasicStatusLine()
-- 	local git_branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
-- 	local branch_section = git_branch ~= "" and (" (" .. git_branch .. ")") or ""
-- 	local statusline = "[%n] %<%f %h%w%m%r" .. branch_section .. "%=%-14.(%l,%c%V%) %P"
-- 	return statusline
-- end
--
-- vim.o.statusline = "%!v:lua.BasicStatusLine()"
vim.diagnostic.config({
	virtual_text = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
	},
})
