--SPECIAL: safe mode (read-only + navigation)
vim.g.safe = false

---@alias RhsCallback fun(): nil
---@alias Rhs string | RhsCallback

---@class KeymapEntry
---@field lhs string
---@field mode string

---@type KeymapEntry[]
local mode_keymaps = {}

---@param mode string | string[]
---@param lhs string
---@param rhs Rhs
---@param desc? string
local function set_mode_keymap(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { buffer = 0, silent = true, desc = desc })
	local modes = type(mode) == "table" and mode or { mode }
	for _, m in ipairs(modes) do
		table.insert(mode_keymaps, { lhs = lhs, mode = m })
	end
end

local function exit_safe_mode()
	if not vim.g.safe then
		return
	end
	vim.g.safe = false
	vim.bo.modifiable = true
	for _, entry in ipairs(mode_keymaps) do
		pcall(vim.keymap.del, entry.mode, entry.lhs, { buffer = 0 })
	end
	mode_keymaps = {}
	vim.api.nvim_exec_autocmds("ModeChanged", {})
end

local function toggle_safe_mode()
	if vim.g.safe then
		exit_safe_mode()
		return
	end
	vim.bo.modifiable = false
	vim.g.safe = true
	-- stop any active macro recording before entering safe mode
	if vim.fn.reg_recording() ~= "" then
		vim.api.nvim_feedkeys("q", "n", false)
	end
	local blocked = {
		"i",
		"I",
		"a",
		"A",
		"o",
		"O", -- insert
		"d",
		"D",
		"dd", -- delete
		"c",
		"C",
		"cc", -- change
		"x",
		"X", -- delete char
		"r",
		"R", -- replace
		"gu",
		"gU",
		"gcc", -- case/comment
		"p",
		"P", -- paste
		"u",
		"<C-r>",
		"<C-a>",
		"<C-x>", -- undo/redo/inc/dec
		"~",
		"=",
		"<",
		">", -- case/indent
		"J", -- join lines
		"q",
		"Q",
		"@",
		".", -- macros/repeat
		"<C-z>",
		"ZZ",
		"ZQ",
		"<leader>ca",
		"<leader>cA", -- code actions
		"<leader>cr",
		"<leader>cR", -- rename
		"<leader>cf",
		"<leader>cF", -- format
	}
	for _, lhs in ipairs(blocked) do
		set_mode_keymap("n", lhs, "<Nop>", "Safe: blocked")
	end
	set_mode_keymap("n", "<Esc>", exit_safe_mode, "Safe: exit")
	vim.api.nvim_exec_autocmds("ModeChanged", {})
end

vim.keymap.set("n", "<leader>ts", toggle_safe_mode, { desc = "Toggle SAFE mode" })
vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
	callback = function()
		if vim.g.safe then
			exit_safe_mode()
		end
	end,
})
