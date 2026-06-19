---@class Statusline.ModeInfo
---@field icon? string
---@field label string
---@field safe_mode_label? string
---@field hl string

---@type table<string, Statusline.ModeInfo>
local mode_map = {
	n = { icon = "", label = "NORMAL", safe_mode_label = "SAFE", hl = "StatusLineNormal" },
	no = { icon = "", label = "O-PENDING", safe_mode_label = "O-SAFE", hl = "StatusLineNormal" },
	i = { icon = "", label = "INSERT", hl = "StatusLineInsert" },
	v = { icon = "", label = "VISUAL", safe_mode_label = "S-VISUAL", hl = "StatusLineVisual" },
	V = { icon = "", label = "V-LINE", safe_mode_label = "S-V-LINE", hl = "StatusLineVisual" },
	["\22"] = { label = "V-BLOCK", safe_mode_label = "S-V-BLOCK", hl = "StatusLineVisual" },
	c = { label = "COMMAND", hl = "StatusLineCommand" },
	R = { label = "REPLACE", hl = "StatusLineReplace" },
	t = { label = "TERMINAL", hl = "StatusLineTerminal" },
}

vim.o.showcmdloc = "statusline"
vim.o.showcmd = true
vim.o.showmode = false --do not show -- INSERT -- etc in the command line since we have it in the statusline

local current_git_branch = ""
--
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
	callback = function()
		current_git_branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
	end,
})

-- Global because 'statusline' evaluates it via `v:lua.CustomStatusline()`.
---@return string
function _G.CustomStatusline()
	if vim.g.statusline_winid ~= vim.fn.win_getid() then
		return "" -- inactive window shows nothing
	end
	local mode = vim.fn.mode()
	local mode_info = mode_map[mode] or { label = "UNKNOWN", hl = "StatusLineNC" }
	local mode_label = vim.g.safe and (mode_info.safe_mode_label or mode_info.label) or mode_info.label
	local time_section = "  " .. os.date("%R") .. " "

	local git_section = current_git_branch ~= "" and (" 󰊢 " .. current_git_branch) or ""

	local warnings_table = vim.diagnostic.count(0, { severity = vim.diagnostic.severity.WARN })
	local warnings_count = warnings_table[vim.diagnostic.severity.WARN] or 0
	local errors_table = vim.diagnostic.count(0, { severity = vim.diagnostic.severity.ERROR })
	local errors_count = errors_table[vim.diagnostic.severity.ERROR] or 0
	local statusline = table.concat({
		"%#" .. mode_info.hl .. "#",
		" " .. mode_label .. " ",
		"%#StatusLineSep#",
		"│",
		"%#StatusLineFile#",
		" 󰈚 %<%f %h%w%m%r", -- %< truncate if too long
		"%#StatusLineBranch#",
		git_section,

		-- "%=", -- everything before is left aligned
		"%=", -- everything after is right aligned
		"%#DiagnosticWarn#",
		warnings_count,
		"%#StatusLineBranch#",
		" : ",
		"%#DiagnosticError#",
		errors_count .. " ",
		"%#StatusLineKeys#",
		" %S ",
		"%#StatusLineVisual#",
		time_section,
		"%#StatusLinePos#",
		" 󰆌 %-5.(%l,%c%V%)", -- [num] =min-width [.] = separator [-] = left align, without it right align, [()] = group, [(%] = start of group, [%)] = end of group
		"%#StatusLinePercent#",
		" 󰏰 %P ",
	})

	return statusline
end

vim.o.statusline = "%!v:lua.CustomStatusline()"
