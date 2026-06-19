-- Toggleable bottom terminal split.
-- Module exposes `toggle`; the keymaps that drive it live in keymaps.lua.

---@class Terminal
local M = {}

---@type integer? scratch/terminal buffer, reused across toggles
local terminal_buf = nil
---@type integer? current split window, nil when hidden
local terminal_win = nil
---@type integer remembered height so the split reopens at the same size
local terminal_win_height = 15

---@return nil
function M.toggle()
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

return M
