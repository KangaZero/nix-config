vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",
	-- On NixOS: managed by pkgs.vimPlugins.telescope-fzf-native-nvim in neovim.nix
	-- (vim.pack cannot compile libfzf.so at runtime; Nix pre-builds it)
	-- On non-Nix: uncomment to let vim.pack download and build it:
	-- "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
})

---@alias telescope.Theme "dropdown"|"ivy"|"cursor"

---@class telescope.PickerOpts
---@field theme? telescope.Theme
---@field hidden? boolean
---@field find_command? string[]
---@field sort_mru? boolean
---@field ignore_current_buffer? boolean
---@field jump_type? "never"|"tab"|"split"|"vsplit"
---@field show_line? boolean

---@class telescope.DefaultsOpts
---@field layout_strategy? "horizontal"|"vertical"|"flex"|"cursor"|"center"|"bottom_pane"
---@field layout_config? table<string, any>
---@field path_display? string[]|table<string, any>
---@field file_ignore_patterns? string[]

---@class telescope.SetupOpts
---@field defaults? telescope.DefaultsOpts
---@field pickers? table<string, telescope.PickerOpts>
---@field extensions? table<string, table<string, any>>

---@type telescope.SetupOpts
local opts = {
	defaults = {
		layout_strategy = "horizontal",
		layout_config = {
			horizontal = { preview_width = 0.75 },
			width = 0.87,
			height = 0.80,
		},
		path_display = { "truncate" },
		file_ignore_patterns = { "node_modules", "%.git/" },
	},
	-- No per-picker `theme` here on purpose. The dropdown theme forces
	-- layout_strategy = "center" and caps the window at 80 columns x 15 rows, which
	-- overrode the `defaults` above and left almost no room for the preview. Without
	-- it these pickers inherit the horizontal layout and its 75% preview pane.
	pickers = {
		find_files = {
			hidden = true,
			find_command = vim.fn.executable("fd") == 1
					and { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--follow", "--exclude", ".git" }
				or nil,
		},
		buffers = {
			sort_mru = true,
			ignore_current_buffer = true,
		},
		lsp_definitions = {
			jump_type = "never",
		},
		lsp_references = {
			show_line = false,
		},
		-- cursor (not dropdown): diagnostics are most useful anchored where you are.
		diagnostics = { theme = "cursor" },
	},
}
require("telescope").setup(opts)

local function apply_telescope_highlights()
	-- Catppuccin Macchiato palette
	local p = {
		crust = "#181926",
		mantle = "#1e2030",
		base = "#24273a",
		surface0 = "#363a4f",
		surface1 = "#494d64",
		surface2 = "#5b6078",
		overlay0 = "#6e738d",
		text = "#cad3f5",
		mauve = "#c6a0f6",
		green = "#a6da95",
		peach = "#f5a97f",
	}

	local hl = vim.api.nvim_set_hl
	hl(0, "TelescopeNormal", { bg = p.mantle })
	hl(0, "TelescopeBorder", { fg = p.mantle, bg = p.mantle })
	hl(0, "TelescopePromptNormal", { bg = p.surface0 })
	hl(0, "TelescopePromptBorder", { fg = p.surface0, bg = p.surface0 })
	hl(0, "TelescopePromptTitle", { fg = p.crust, bg = p.mauve, bold = true })
	hl(0, "TelescopePreviewTitle", { fg = p.crust, bg = p.green, bold = true })
	hl(0, "TelescopeResultsTitle", { fg = p.mantle, bg = p.mantle })
	hl(0, "TelescopeResultsBorder", { fg = p.mantle, bg = p.mantle })
	hl(0, "TelescopePreviewBorder", { fg = p.mantle, bg = p.mantle })
	hl(0, "TelescopePreviewNormal", { bg = p.base })
	hl(0, "TelescopeSelection", { bg = p.surface1, fg = p.text })
	hl(0, "TelescopeSelectionCaret", { fg = p.mauve, bg = p.surface1 })
	hl(0, "TelescopeMatching", { fg = p.peach, bold = true })
	hl(0, "TelescopePromptCounter", { fg = p.overlay0 })
end

apply_telescope_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_telescope_highlights })

require("telescope").load_extension("fzf")
