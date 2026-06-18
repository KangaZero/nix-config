local M = {}

M.win = nil
M.bg_win = nil
M.bg_buf = nil
M.parent = nil

local function height()
	local h = vim.o.lines - vim.o.cmdheight
	return vim.o.laststatus == 3 and h - 1 or h
end

local function layout(width_pct, height_pct)
	local w = math.floor(vim.o.columns * width_pct)
	local h = math.floor(height() * height_pct)
	return {
		width = w,
		height = h,
		col = math.floor((vim.o.columns - w) / 2),
		row = math.floor((height() - h) / 2),
	}
end

local function is_float(win)
	local cfg = vim.api.nvim_win_get_config(win)
	return cfg and cfg.relative and cfg.relative ~= ""
end

function M.is_open()
	return M.win and vim.api.nvim_win_is_valid(M.win)
end

function M.close()
	pcall(vim.cmd, "autocmd! Zen")
	pcall(vim.cmd, "augroup! Zen")

	if M.win and vim.api.nvim_win_is_valid(M.win) then
		-- sync cursor back to parent
		if M.parent and vim.api.nvim_win_is_valid(M.parent) then
			if vim.api.nvim_win_get_buf(M.parent) == vim.api.nvim_win_get_buf(M.win) then
				vim.api.nvim_win_set_cursor(M.parent, vim.api.nvim_win_get_cursor(M.win))
			end
		end
		vim.api.nvim_win_close(M.win, { force = true })
		M.win = nil
	end

	if M.bg_win and vim.api.nvim_win_is_valid(M.bg_win) then
		vim.api.nvim_win_close(M.bg_win, { force = true })
		M.bg_win = nil
	end

	if M.bg_buf and vim.api.nvim_buf_is_valid(M.bg_buf) then
		vim.api.nvim_buf_delete(M.bg_buf, { force = true })
		M.bg_buf = nil
	end

	if M.parent and vim.api.nvim_win_is_valid(M.parent) then
		vim.api.nvim_set_current_win(M.parent)
	end
end

function M.open(opts)
	opts = vim.tbl_deep_extend("force", {
		width = 0.7,
		height = 1,
		backdrop = 0, -- winblend for backdrop (0-100)
	}, opts or {})

	M.parent = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_get_current_buf()
	local l = layout(opts.width, opts.height)

	-- backdrop
	M.bg_buf = vim.api.nvim_create_buf(false, true)
	M.bg_win = vim.api.nvim_open_win(M.bg_buf, false, {
		relative = "editor",
		width = vim.o.columns,
		height = height(),
		row = 0,
		col = 0,
		focusable = false,
		style = "minimal",
		border = "none",
		zindex = 39,
	})
	vim.api.nvim_win_set_option(M.bg_win, "winblend", opts.backdrop)
	vim.api.nvim_win_set_option(M.bg_win, "winhighlight", "Normal:ZenBg")

	-- zen window
	M.win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = l.width,
		height = l.height,
		row = l.row,
		col = l.col,
		style = "minimal",
		border = "rounded",
		zindex = 40,
	})
	vim.api.nvim_win_set_option(M.win, "winhighlight", "NormalFloat:Normal")
	vim.cmd("norm! zz")

	-- close when leaving the zen window
	vim.api.nvim_exec(
		[[
    augroup Zen
      autocmd!
      autocmd WinClosed %d ++once lua require("custom.zen").close()
      autocmd WinEnter * lua require("custom.zen").on_win_enter()
      autocmd VimResized * lua require("custom.zen").on_resize()
    augroup end
  ]],
		false
	)
end

function M.on_win_enter()
	local win = vim.api.nvim_get_current_win()
	if win ~= M.win and not is_float(win) then
		vim.defer_fn(function()
			if vim.api.nvim_get_current_win() ~= M.win then
				M.close()
			end
		end, 10)
	end
end

function M.on_resize()
	if not M.is_open() then
		return
	end
	local l = layout(0.7, 0.9)
	vim.api.nvim_win_set_config(M.win, { width = l.width, height = l.height })
	vim.api.nvim_win_set_config(M.bg_win, {
		width = vim.o.columns,
		height = height(),
	})
end

function M.toggle(opts)
	if M.is_open() then
		M.close()
	else
		M.open(opts)
	end
end

vim.api.nvim_set_hl(0, "ZenBg", { bg = "#000000" })

return M
