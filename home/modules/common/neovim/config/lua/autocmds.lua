vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "highlight when yanking text",
	callback = function()
		vim.hl.on_yank()
	end,
})

-- For help pages to open as :vsplit
vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "*",
	callback = function()
		if vim.bo.filetype == "help" then
			vim.cmd("wincmd L") -- move to far right as vertical split
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		pcall(vim.treesitter.start)
	end,
})
--
--INFO: Using blink instead
-- vim.api.nvim_create_autocmd("LspAttach", {
-- 	callback = function(event)
-- 		-- local query =
-- 		-- 	'; extends\n\n((comment) @comment.todo\n  (#match? @comment.todo "TODO|FIXME|HACK|NOTE|BUG|PERF"))\n'
-- 		-- local queries_dir = vim.fn.stdpath("config") .. "/after/queries/"
-- 		--
-- 		-- for _, lang in ipairs(vim.tbl_keys(require("nvim-treesitter.parsers").get_parser_configs())) do
-- 		-- 	local dir = queries_dir .. lang
-- 		-- 	vim.fn.mkdir(dir, "p")
-- 		-- 	local f = io.open(dir .. "/highlights.scm", "w")
-- 		-- 	if f then
-- 		-- 		f:write(query)
-- 		-- 		f:close()
-- 		-- 	end
-- 		-- end
-- 		vim.o.signcolumn = "yes:1"
-- 		local client = assert(vim.lsp.get_client_by_id(event.data.client_id))
-- 		-- Do not show on TelescopePrompt
-- 		if client:supports_method("textDocument/completion") then
-- 			vim.o.complete = "o,.,w,b,u,i,d,t" -- h 'cpt'
-- 			vim.o.completeopt = "menu,menuone,preview,fuzzy,popup,noinsert"
-- 			vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
-- 		end
-- 		if client and client:supports_method("textDocument/inlayHint", event.buf) then
-- 			vim.keymap.set("n", "<leader>th", function()
-- 				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
-- 			end, { desc = "[T]oggle Inlay [H]ints" })
-- 		end
-- 	end,
-- })

local close_with_q_augroup = vim.api.nvim_create_augroup("close_with_q", { clear = true })
-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	group = close_with_q_augroup,
	pattern = {
		"PlenaryTestPopup",
		"checkhealth",
		"dap-float",
		"dbout",
		"gitsigns-blame",
		"grug-far",
		"help",
		"terminal",
		"lazygit",
		-- "lspinfo",
		"TelescopePrompt",
		"nvim-undotree",
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"notify",
		"qf",
		"spectre_panel",
		"startuptime",
		"tsplayground",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.schedule(function()
			-- Do not show any autocomplete when in Telescope buffer
			if vim.bo.filetype == "TelescopePrompt" then
				vim.bo.complete = ""
			end
			vim.keymap.set("n", "q", function()
				vim.cmd("close")
				pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
			end, {
				buffer = event.buf,
				silent = true,
				desc = "Quit buffer",
			})
		end)
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		if vim.fn.has("nvim-0.12") == 0 then
			return
		end
		--TODO auto highlight special comments
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
		-- Replace with this if native formatter is used
		-- if vim.fn.has("nvim-0.12") == 0 then
		-- 	return
		-- end
		-- vim.lsp.buf.format()
	end,
})

vim.api.nvim_create_autocmd({ "BufLeave" }, {
	callback = function()
		if vim.bo.modified and vim.bo.buftype == "" then
			-- save file by default
			vim.cmd("silent! w")
			vim.lsp.buf.format()
		end
		-- get full path of current file
		local file = vim.fn.expand("%:p")

		-- check if it ends with ".lua"::
		if file:match("^" .. vim.fn.stdpath("config") .. "/.*%.lua$") then
			vim.cmd("source %")
			-- vim.notify("🔁 reloaded " .. file, vim.log.levels.INFO)
		end
	end,
	nested = true,
})
