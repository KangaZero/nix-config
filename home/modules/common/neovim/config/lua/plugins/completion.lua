vim.pack.add({
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("^1"),
	},
	-- VSCode-format snippets for 40+ languages; blink's snippets source picks
	-- these up automatically from runtimepath — no setup call needed.
	"https://github.com/rafamadriz/friendly-snippets",
})

-- ---@class BlinkCopilotConfig
-- ---@field max_completions integer Maximum number of completions to show
-- ---@field max_attempts? integer Maximum number of attempts to fetch completions
-- ---@field kind_name string|false The name of the kind
-- ---@field kind_icon string|false The icon of the kind
-- ---@field kind_hl string|false The highlight group of the kind
-- ---@field debounce integer|false Debounce time in milliseconds
-- ---@field auto_refresh? {backward?: boolean, forward?: boolean} Whether to auto-refresh completions
-- require("blink-copilot").setup({
-- 	max_completions = 2,
-- 	max_attempts = 4,
-- 	kind_name = "Copilot", ---@type string | false
-- 	kind_icon = "󰚑 ", ---@type string | false
-- 	kind_hl = false, ---@type string | false
-- 	debounce = 200, ---@type integer | false
-- 	auto_refresh = {
-- 		backward = true,
-- 		forward = true,
-- 	},
-- }),

-- Nekonight deep-ocean palette — mirrors colorscheme.lua so blink windows feel native
local p = {
	bg_dark = "#090B10", -- darkest bg: menu/doc window background
	bg = "#0F111A", -- base bg
	bg_hl = "#1b1524", -- hover / selection row
	fg = "#c0caf5", -- primary text
	fg_dark = "#a9b1d6", -- secondary text / descriptions
	comment = "#546E7A", -- muted / ghost text
	blue = "#82AAFF", -- functions, methods, files
	cyan = "#7dcfff", -- operators, references
	teal = "#4fd6be", -- folders, type params
	green = "#C3E88D", -- fields, variables, properties
	yellow = "#efbd5d", -- classes, enums, values
	orange = "#dd9046", -- constants, events
	magenta = "#c099ff", -- keywords, selection border (matches WinSeparator)
	purple = "#C792EA", -- constructors, snippets
	red = "#f65866", -- errors / deprecated
}

-- Source label short-names shown in the menu's rightmost column
local source_labels = {
	LSP = "lsp",
	Path = "path",
	Snippets = "snip",
	Buffer = "buf",
}

local function apply_blink_highlights()
	local hl = vim.api.nvim_set_hl

	-- Menu window — darkest bg so it floats above editor (matches colorscheme.lua bg_dark)
	hl(0, "BlinkCmpMenu", { bg = p.bg_dark, fg = p.fg })
	hl(0, "BlinkCmpMenuBorder", { fg = p.magenta, bg = p.bg_dark })
	hl(0, "BlinkCmpMenuSelection", { bg = p.bg_hl, fg = p.fg, bold = true })

	-- Documentation window — slightly lighter than menu
	hl(0, "BlinkCmpDoc", { bg = p.bg, fg = p.fg })
	hl(0, "BlinkCmpDocBorder", { fg = p.magenta, bg = p.bg })
	hl(0, "BlinkCmpDocSeparator", { fg = p.magenta, bg = p.bg })
	hl(0, "BlinkCmpDocCursorLine", { bg = p.bg_hl })

	-- Label text
	hl(0, "BlinkCmpLabel", { fg = p.fg })
	hl(0, "BlinkCmpLabelMatch", { fg = p.magenta, bold = true })
	hl(0, "BlinkCmpLabelDeprecated", { fg = p.comment, strikethrough = true })
	hl(0, "BlinkCmpLabelDetail", { fg = p.comment })
	hl(0, "BlinkCmpLabelDescription", { fg = p.fg_dark })

	-- Kind icons — sourced directly from deep-ocean palette
	hl(0, "BlinkCmpKindText", { fg = p.fg_dark })
	hl(0, "BlinkCmpKindMethod", { fg = p.blue })
	hl(0, "BlinkCmpKindFunction", { fg = p.blue })
	hl(0, "BlinkCmpKindConstructor", { fg = p.purple })
	hl(0, "BlinkCmpKindField", { fg = p.green })
	hl(0, "BlinkCmpKindVariable", { fg = p.green })
	hl(0, "BlinkCmpKindProperty", { fg = p.green })
	hl(0, "BlinkCmpKindClass", { fg = p.yellow })
	hl(0, "BlinkCmpKindInterface", { fg = p.yellow })
	hl(0, "BlinkCmpKindStruct", { fg = p.yellow })
	hl(0, "BlinkCmpKindModule", { fg = p.cyan })
	hl(0, "BlinkCmpKindUnit", { fg = p.teal })
	hl(0, "BlinkCmpKindValue", { fg = p.orange })
	hl(0, "BlinkCmpKindEnum", { fg = p.yellow })
	hl(0, "BlinkCmpKindEnumMember", { fg = p.yellow })
	hl(0, "BlinkCmpKindKeyword", { fg = p.magenta })
	hl(0, "BlinkCmpKindConstant", { fg = p.orange })
	hl(0, "BlinkCmpKindSnippet", { fg = p.purple })
	hl(0, "BlinkCmpKindColor", { fg = p.red })
	hl(0, "BlinkCmpKindFile", { fg = p.blue })
	hl(0, "BlinkCmpKindReference", { fg = p.cyan })
	hl(0, "BlinkCmpKindFolder", { fg = p.teal })
	hl(0, "BlinkCmpKindEvent", { fg = p.orange })
	hl(0, "BlinkCmpKindOperator", { fg = p.cyan })
	hl(0, "BlinkCmpKindTypeParameter", { fg = p.teal })

	-- Ghost text — muted, italic so it's clearly not real text
	hl(0, "BlinkCmpGhostText", { fg = p.comment, italic = true })

	-- Signature help — matches doc window style
	hl(0, "BlinkCmpSignatureHelpBorder", { fg = p.magenta, bg = p.bg })
	hl(0, "BlinkCmpSignatureHelpActiveParameter", { fg = p.magenta, bold = true, underline = true })
end

apply_blink_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_blink_highlights })

-- INFO: Source https://tduyng.com/blog/neovim-auto-completions/
vim.api.nvim_create_autocmd("InsertEnter", {
	pattern = "*",
	group = vim.api.nvim_create_augroup("BlinkCmpLazyLoad", { clear = true }),
	once = true,
	callback = function()
		---@type blink.cmp.Config
		local opts = {
			-- Keymap presets:
			--   'default'   — C-y to accept (built-in completion style)
			--   'super-tab' — Tab to accept (VS Code style)
			--   'enter'     — Enter to accept
			--   'none'      — no preset mappings
			--
			-- Shared across all presets:
			--   C-space: open menu / open docs if menu already open
			--   C-n/C-p or Up/Down: select next/previous item
			--   C-e: hide menu
			--   C-k: toggle signature help (requires signature.enabled = true)
			--
			-- See :h blink-cmp-config-keymap for custom mappings
			keymap = {
				preset = "super-tab",
				-- 'accept' handles ghost text when menu is closed.
				-- 'select_and_accept' handles the highlighted item when menu is open.
				-- Both needed — they cover different states.
				["<Tab>"] = { "accept", "snippet_forward", "fallback" },
				["<C-Y>"] = { "select_and_accept" },
			},

			appearance = {
				nerd_font_variant = "mono",
				-- false: use the BlinkCmp* highlights defined above instead of
				-- falling back to nvim-cmp's groups.
				use_nvim_cmp_as_default = false,
			},

			completion = {
				accept = {
					-- Automatically insert closing bracket/paren after accepting.
					-- Experimental — disable if it fights with your snippets.
					auto_brackets = { enabled = true },
				},

				menu = {
					border = "rounded",
					-- winhighlight links the float's normal/border/selection groups
					-- to the BlinkCmp* highlights defined above.
					winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
					scrollbar = true,
					draw = {
						-- Align the typed prefix to the label column (default, looks cleanest)
						align_to = "label",
						padding = { 0, 1 },
						gap = 1,
						-- Use treesitter to syntax-highlight label text for LSP items
						treesitter = { "lsp" },
						-- Three columns: [icon] [label + detail] [source badge]
						columns = {
							{ "kind_icon" },
							{ "label", "label_description", gap = 1 },
							{ "source_name" },
						},
						components = {
							kind_icon = {
								ellipsis = false,
								text = function(ctx)
									-- Snippets get a dedicated icon regardless of kind
									if ctx.source_name == "Snippets" then
										return "󱄽 "
									end
									return ctx.kind_icon .. ctx.icon_gap
								end,
								highlight = function(ctx)
									return { { group = ctx.kind_hl, priority = 20000 } }
								end,
							},
							label = {
								width = { fill = true, max = 60 },
								text = function(ctx)
									return ctx.label .. (ctx.label_detail or "")
								end,
								highlight = function(ctx)
									local label = ctx.label
									local highlights = {
										{
											0,
											#label,
											group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
										},
									}
									if ctx.label_detail then
										table.insert(highlights, {
											#label,
											#label + #ctx.label_detail,
											group = "BlinkCmpLabelDetail",
										})
									end
									return highlights
								end,
							},
							-- Rightmost column: short source badge (lsp / path / snip / buf)
							source_name = {
								width = { max = 6 },
								text = function(ctx)
									return source_labels[ctx.source_name] or ctx.source_name:lower():sub(1, 4)
								end,
								highlight = function(_)
									return "BlinkCmpLabelDescription"
								end,
							},
						},
					},
				},

				documentation = {
					auto_show = true,
					-- 0 ms: show docs immediately on selection (no flicker delay)
					auto_show_delay_ms = 0,
					treesitter_highlighting = true,
					window = {
						border = "rounded",
						winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
						scrollbar = true,
					},
				},

				ghost_text = {
					enabled = true,
				},
			},

			-- Sources are tried in priority order (score_offset breaks ties).
			-- To add a source elsewhere without redefining this list, use opts_extend.
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				providers = {
					lsp = { score_offset = 100 },
					path = { score_offset = 97 },
					buffer = { score_offset = 95 },
					-- Snippets ranked last — useful but rarely what you want first
					snippets = { score_offset = -100 },

					-- copilot = { name = "copilot", module = "copilot", score_offset = 90, async = true },
				},
				per_filetype = {
					opencode_ask = { "lsp", "buffer" },
				},
			},

			-- prefer_rust_with_warning: uses the Rust fuzzy matcher when available
			-- (significantly faster on large projects), warns if it falls back to Lua.
			fuzzy = { implementation = "prefer_rust_with_warning" },
		}
		require("blink.cmp").setup(opts)
	end,
})
