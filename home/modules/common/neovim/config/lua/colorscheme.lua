---@diagnostic disable: unused-local
vim.pack.add({
	"https://github.com/neko-night/nvim",
})

--- NOTE: plugins/telesccope also has its own colorscheme applied on its own file
---@class nekonight.Config
require("nekonight").setup({
	style = "night",
	transparent = true,
	terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
	styles = {
		sidebars = "transparent",
		floats = "transparent",
	},
	--- You can override specific color groups to use other groups or a hex color
	--- function will be called with a ColorScheme table
	---@param colors ColorScheme
	on_colors = function(colors) end,

	plugins = {
		all = false,
		auto = false,
		-- telescope = true,
		["which-key"] = true,
	},
	--- You can override specific highlights to use other groups or a hex color
	--- function will be called with a Highlights and ColorScheme table
	---@param highlights nekonight.Highlights
	---@param colors ColorScheme
	on_highlights = function(highlights, colors)
		local prompt = "#2d3149"
		highlights.TelescopeNormal = {
			bg = colors.bg_dark,
			fg = colors.fg_dark,
		}
		highlights.TelescopeBorder = {
			bg = colors.bg_dark,
			fg = colors.bg_dark,
		}
		highlights.TelescopePromptNormal = {
			bg = prompt,
		}
		highlights.TelescopePromptBorder = {
			bg = prompt,
			fg = prompt,
		}
		highlights.TelescopePromptTitle = {
			bg = prompt,
			fg = prompt,
		}
		highlights.TelescopePreviewTitle = {
			bg = colors.bg_dark,
			fg = colors.bg_dark,
		}
		highlights.TelescopeResultsTitle = {
			bg = colors.bg_dark,
			fg = colors.bg_dark,
		}
	end,
})

vim.cmd.colorscheme("nekonight-deep-ocean")

vim.api.nvim_set_hl(0, "SpellBad", {
	undercurl = true,
	fg = "#f38ba8",
})
-- --INFO: Nekonight does not fully fit my wallpaper, so I need to adjust some colors to make it look better
if vim.g.colors_name == "nekonight-deep-ocean" then
	vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#c099ff" })
	vim.api.nvim_set_hl(0, "CursorLine", { bg = "#232323" })
	vim.api.nvim_set_hl(0, "LineNr", { fg = "#767676" })
	vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#767676" })
	vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#767676" })
end
-- Statusline Highlights
vim.api.nvim_set_hl(0, "StatusLineNormal", { fg = "#232323", bg = "#89b4fa", bold = true })
vim.api.nvim_set_hl(0, "StatusLineInsert", { fg = "#232323", bg = "#a6e3a1", bold = true })
vim.api.nvim_set_hl(0, "StatusLineVisual", { fg = "#232323", bg = "#c099ff", bold = true })
vim.api.nvim_set_hl(0, "StatusLineCommand", { fg = "#232323", bg = "#f9e2af", bold = true })
vim.api.nvim_set_hl(0, "StatusLineReplace", { fg = "#232323", bg = "#f38ba8", bold = true })
vim.api.nvim_set_hl(0, "StatusLineTerminal", { fg = "#232323", bg = "#94e2d5", bold = true })
vim.api.nvim_set_hl(0, "StatusLineSep", { fg = "#45475a" })
vim.api.nvim_set_hl(0, "StatusLineFile", { fg = "#89b4fa", bold = true })
vim.api.nvim_set_hl(0, "StatusLineBranch", { fg = "#a6e3a1", italic = true })
vim.api.nvim_set_hl(0, "StatusLinePos", { fg = "#c099ff" })
vim.api.nvim_set_hl(0, "StatusLinePercent", { fg = "#f38ba8" })
vim.api.nvim_set_hl(0, "StatusLineSymbol", { fg = "#f9e2af", italic = true })
vim.api.nvim_set_hl(0, "StatusLineKeys", { fg = "#cba6f7" })

-- Pager Highlights (eg. :messages)
vim.api.nvim_set_hl(0, "MsgArea", { fg = "#cdd6f4", bg = "#1e1e2e" })
vim.api.nvim_set_hl(0, "MsgSeparator", { fg = "#45475a", bg = "#1e1e2e" })
vim.api.nvim_set_hl(0, "MoreMsg", { fg = "#a6e3a1", bold = true })
vim.api.nvim_set_hl(0, "ErrorMsg", { fg = "#f38ba8", bold = true })
vim.api.nvim_set_hl(0, "WarningMsg", { fg = "#f9e2af", bold = true })
vim.api.nvim_set_hl(0, "Question", { fg = "#89b4fa", bold = true })

-- Dashboard Highlights
-- vim.api.nvim_set_hl(0, "DashboardHeader1", { fg = "#52208f" })
-- vim.api.nvim_set_hl(0, "DashboardHeader2", { fg = "#5e2a9b" })
-- vim.api.nvim_set_hl(0, "DashboardHeader3", { fg = "#6a35a8" })
-- vim.api.nvim_set_hl(0, "DashboardHeader4", { fg = "#7641b3" })
-- vim.api.nvim_set_hl(0, "DashboardHeader5", { fg = "#824dbf" })
-- vim.api.nvim_set_hl(0, "DashboardHeader6", { fg = "#8f5dc9" })
-- vim.api.nvim_set_hl(0, "DashboardHeader7", { fg = "#9b6dd4" })
-- vim.api.nvim_set_hl(0, "DashboardHeader8", { fg = "#a87fda" })
-- vim.api.nvim_set_hl(0, "DashboardHeader9", { fg = "#b591e0" })
-- vim.api.nvim_set_hl(0, "DashboardHeader10", { fg = "#d4baee" })
