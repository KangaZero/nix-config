vim.pack.add({ "https://github.com/rachartier/tiny-inline-diagnostic.nvim" })

local opts = {
	preset = "modern",
	transparent_bg = true,
	hi = {
		error = "DiagnosticError",
		warn = "DiagnosticWarn",
		info = "DiagnosticInfo",
		hint = "DiagnosticHint",
		arrow = "NonText",
		background = "CursorLine",
		mixing_color = "Normal",
	},
	options = {
		show_source = {
			enabled = true,
			if_many = false,
		},
		show_code = true,
		show_related = {
			enabled = true,
			max_count = 3,
		},
		add_messages = {
			messages = true,
			display_count = true,
			use_max_severity = false,
			show_multiple_glyphs = true,
		},
		set_arrow_to_diag_color = false,
		use_icons_from_diagnostic = true,
		throttle = 20,
		softwrap = 30,
		multilines = {
			enabled = true,
			always_show = false,
			trim_whitespaces = true,
			tabstop = 4,
			severity = nil,
		},
		show_all_diags_on_cursorline = false,
		show_diags_only_under_cursor = false,
		enable_on_insert = false,
		enable_on_select = false,
		format = nil,
		overflow = {
			mode = "wrap",
		},
		break_line = {
			enabled = false,
			after = 30,
		},
		virt_texts = {
			priority = 2048,
		},
		severity = {
			vim.diagnostic.severity.ERROR,
			vim.diagnostic.severity.WARN,
			vim.diagnostic.severity.INFO,
			vim.diagnostic.severity.HINT,
		},
		override_open_float = false,
		overwrite_events = nil,
		experimental = {
			use_window_local_extmarks = false,
		},
	},
	disabled_ft = {},
}

require("tiny-inline-diagnostic").setup(opts)
