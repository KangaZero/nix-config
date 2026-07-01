--- @class Util
local M = {}
--- @class RGB
--- @field r number
--- @field g number
--- @field b number
---
--- @param name string
--- @return vim.api.keyset.get_hl_info|nil
function M.get_hl(name)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name })
	if not ok then
		return
	end
	for _, key in pairs({ "foreground", "background", "special" }) do
		if hl[key] then
			hl[key] = string.format("#%06x", hl[key])
		end
	end
	return hl
end

--- @param c number
--- @return number
local function rgb_to_linear(c)
	c = c / 255
	return c <= 0.04045 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
end

--- @param color RGB
--- @return number
local function relative_luminance(color)
	return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b
end

--- @param hex string
--- @return RGB|nil
function M.hex2linear_srgb(hex)
	hex = hex:gsub("#", "")
	local r = tonumber("0x" .. hex:sub(1, 2))
	local g = tonumber("0x" .. hex:sub(3, 4))
	local b = tonumber("0x" .. hex:sub(5, 6))
	if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then
		return nil
	end
	return {
		r = rgb_to_linear(r),
		g = rgb_to_linear(g),
		b = rgb_to_linear(b),
	}
end

--- @param c1 RGB
--- @param c2 RGB
--- @return number
function M.contrast_ratio(c1, c2)
	local lum1 = relative_luminance(c1)
	local lum2 = relative_luminance(c2)

	if lum1 < lum2 then
		lum1, lum2 = lum2, lum1
	end

	return (lum1 + 0.05) / (lum2 + 0.05)
end

--- @param base string
--- @param fg1 string
--- @param fg2 string
--- @return string|nil
function M.maximize_contrast(base, fg1, fg2)
	local rgb_base = M.hex2linear_srgb(base)
	local rgb_fg1 = M.hex2linear_srgb(fg1)
	local rgb_fg2 = M.hex2linear_srgb(fg2)
	if rgb_base == nil or rgb_fg1 == nil or rgb_fg2 == nil then
		return nil
	end
	return M.contrast_ratio(rgb_base, rgb_fg1) > M.contrast_ratio(rgb_base, rgb_fg2) and fg1 or fg2
end

--- @param msg string
--- @return nil
function M.warn(msg)
	vim.notify(msg, vim.log.levels.WARN, { title = "Util" })
end

--- @param msg string
--- @return nil
function M.error(msg)
	vim.notify(msg, vim.log.levels.ERROR, { title = "Util" })
end

--- @param buf integer
--- @param title string
--- @param width? number fraction of screen width (0-1)
--- @param height? number fraction of screen height (0-1)
--- @param system_cmd? string|string[] --if no system_cmd provided it will simply launch the terminal
--- @param cwd? string
--- @param row? number
--- @param col? number
function M.create_popup_term_win(buf, title, width, height, system_cmd, cwd, row, col)
	if width and width > 1 then
		vim.notify("create_popup_win: width must be a fraction between 0 and 1, got " .. width, vim.log.levels.ERROR)
		return
	end
	if height and height > 1 then
		vim.notify("create_popup_win: height must be a fraction between 0 and 1, got " .. height, vim.log.levels.ERROR)
		return
	end

	local w = math.floor(vim.o.columns * (width or 0.8))
	local h = math.floor(vim.o.lines * (height or 0.8))
	row = row or math.floor((vim.o.lines - h) / 2)
	col = col or math.floor((vim.o.columns - w) / 2)
	cwd = cwd or vim.fn.expand("%:p:h")

	vim.bo[buf].filetype = title
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = w,
		height = h,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " " .. title .. " ",
		title_pos = "center",
	})

	if system_cmd then
		vim.fn.jobstart(system_cmd, {
			cwd = cwd,
			detach = false,
			term = true,
			-- on_exit = function()
			-- 	if vim.api.nvim_buf_is_valid(buf) then
			-- 		vim.api.nvim_buf_delete(buf, { force = true })
			-- 	end
			-- end,
		})
	else
		do
			vim.api.nvim_open_term(buf, {})
		end
	end

	vim.cmd("startinsert")
end

function M.get_lsp_symbol()
	-- if not lsp clients for current buf, early return
	if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
		return ""
	end
	local ok, result = pcall(vim.lsp.buf_request_sync, 0, "textDocument/documentSymbol", {
		textDocument = vim.lsp.util.make_text_document_params(),
	}, 500)
	if not ok or not result then
		return ""
	end

	local cursor = vim.api.nvim_win_get_cursor(0)
	local line = cursor[1] - 1

	local function find_symbol(symbols, parent)
		for _, symbol in ipairs(symbols or {}) do
			local range = symbol.range or (symbol.location and symbol.location.range)
			if range and line >= range.start.line and line <= range["end"].line then
				local name = (parent and (parent .. " > ") or "") .. symbol.name
				if symbol.children then
					local child = find_symbol(symbol.children, name)
					if child then
						return child
					end
				end
				return name
			end
		end
	end

	for _, res in pairs(result) do
		if res.result then
			local symbol = find_symbol(res.result, nil)
			if symbol then
				if #symbol > 30 then
					local parts = vim.split(symbol, " > ")
					if #parts > 1 then
						symbol = parts[1] .. " > .. > " .. parts[#parts]
					else
						symbol = symbol:sub(1, 27) .. "..."
					end
				end
				return " 󰊕 " .. symbol
			end
		end
	end
	return ""
end

--- Mutates text on the current line or visual selection using a string transformer
--- @param transform_fn fun(str: string): string
function M.modify_text(transform_fn)
	local mode = vim.api.nvim_get_mode().mode
	if mode:match("[vV]") then
		-- Visual mode processing
		vim.cmd("normal! \27") -- Exit visual mode to grab marks
		local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(0, "<"))
		local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, ">"))
		local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
		if #lines == 0 then
			return
		end

		for i, line in ipairs(lines) do
			local s_col = (i == 1) and start_col + 1 or 1
			local e_col = (i == #lines) and end_col + 1 or #line
			local prefix = line:sub(1, s_col - 1)
			local target = line:sub(s_col, e_col)
			local target_indent, target_content = target:match("^(%s*)(.*)")
			local suffix = line:sub(e_col + 1)
			lines[i] = prefix .. target_indent .. transform_fn(target_content) .. suffix
		end
		vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
	else
		-- Normal mode processing (current line)
		local line = vim.api.nvim_get_current_line()
		local indent, content = line:match("^(%s*)(.*)")
		local transformed_content = transform_fn(content)
		local transformed_line = indent .. transformed_content
		vim.api.nvim_set_current_line(transformed_line)
	end
end

--- @param str string
function M.to_kebab(str)
	local res = str:gsub("^(%s?+)([a-z0-9])([A-Z])", "%1%2-%3")
	res = res:gsub("([A-Z])([A-Z][a-z])", "%1-%2")
	return res:gsub("[_%s]+", "-"):lower()
end

--- @param str string
function M.to_pascal(str)
	local res = str:gsub("^%l", string.upper)
	res = res:gsub("[-_%s]+(%l)", function(c)
		return c:upper()
	end)
	return res:gsub("[-_%s]", "")
end

--- @param str string
function M.to_camel(str)
	local res = M.to_pascal(str)
	res = str:gsub("^%u", string.lower)
	return res
end

--- @param str string
function M.to_snake(str)
	local res = M.to_kebab(str)
	return res:gsub("-", "_")
end

return M
