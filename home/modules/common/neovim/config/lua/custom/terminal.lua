local terminal_buf = nil
local terminal_win = nil
local terminal_win_height = 15

local function toggle_terminal()
	-- If window is open, hide it
	if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
		terminal_win_height = vim.api.nvim_win_get_height(terminal_win) -- save height for next time
		vim.api.nvim_win_hide(terminal_win)
		terminal_win = nil
		return
	end

	-- Create buffer if it doesn't exist yet
	if not terminal_buf or not vim.api.nvim_buf_is_valid(terminal_buf) then
		terminal_buf = vim.api.nvim_create_buf(false, true)
	end

	-- Open a split at the bottom and put our buffer in it
	vim.cmd("botright split")
	terminal_win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(terminal_win, terminal_buf)
	vim.api.nvim_win_set_height(terminal_win, terminal_win_height)

	-- If buffer has no terminal yet, open one
	if vim.bo[terminal_buf].buftype ~= "terminal" then
		vim.cmd("terminal")
		terminal_buf = vim.api.nvim_get_current_buf() -- terminal cmd replaces the buf
	end

	vim.cmd("startinsert")
end

vim.keymap.set({ "n", "v", "t" }, "<C-/>", toggle_terminal, { desc = "Toggle terminal" })

-- Esc to go back to normal mode inside terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Enter normal mode in terminal" })
