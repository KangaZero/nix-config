vim.pack.add({
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("^1"),
	},
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
-- INFO: Source https://tduyng.com/blog/neovim-auto-completions/
vim.api.nvim_create_autocmd("InsertEnter", {
	pattern = "*",
	group = vim.api.nvim_create_augroup("BlinkCmpLazyLoad", { clear = true }),
	once = true,
	callback = function()
		---@type blink.cmp.Config
		local opts = {
			-- 	-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
			-- 	-- 'super-tab' for mappings similar to vscode (tab to accept)
			-- 	-- 'enter' for enter to accept
			-- 	-- 'none' for no mappings
			-- 	--
			-- 	-- All presets have the following mappings:
			-- 	-- C-space: Open menu or open docs if already open
			-- 	-- C-n/C-p or Up/Down: Select next/previous item
			-- 	-- C-e: Hide menu
			-- 	-- C-k: Toggle signature help (if signature.enabled = true)
			-- 	--
			-- 	-- See :h blink-cmp-config-keymap for defining your own keymap
			keymap = {
				preset = "super-tab",
				-- 'accept' handles ghost text (menu closed); 'select_and_accept' handles menu selection.
				-- Both are needed because they cover different states.
				["<Tab>"] = { "accept", "snippet_forward", "fallback" },
				["<C-Y>"] = { "select_and_accept" },
			},
			appearance = {
				nerd_font_variant = "mono",
				use_nvim_cmp_as_default = true,
			},
			completion = {
				accept = {
					-- experimental auto-brackets support
					auto_brackets = {
						enabled = true,
					},
				},
				menu = {
					draw = {
						treesitter = { "lsp" },
						components = {
							kind_icon = {
								text = function(ctx)
									if ctx.source_name == "Snippets" then
										return ""
									end
									return ctx.kind_icon .. " "
								end,
							},
						},
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 0,
				},
				ghost_text = {
					enabled = true,
					-- auto_show_delay_ms = 100,
					-- enabled = vim.g.ai_cmp,
				},
			},

			-- Default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				providers = {
					lsp = { score_offset = 100 },
					snippets = { score_offset = -100 },
					path = { score_offset = 97 },
					buffer = { score_offset = 95 },

					-- copilot = { name = "copilot", module = "copilot", score_offset = 90, async = true },
				},
				per_filetype = {
					opencode_ask = { "lsp", "buffer" },
				},
			},
			fuzzy = { implementation = "prefer_rust_with_warning" },
		}
		require("blink.cmp").setup(opts)
	end,
})
