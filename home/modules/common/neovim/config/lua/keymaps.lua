-- Alt+hjkl to move between windows from any mode
vim.keymap.set({ "t", "i" }, "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Go to Left Window" })
vim.keymap.set({ "t" }, "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Go to Lower Window" })
vim.keymap.set({ "t", "i" }, "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Go to Upper Window" })
vim.keymap.set({ "t", "i" }, "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Go to Right Window" })

vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz")
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz")
vim.keymap.set({ "n", "v" }, "<C-b>", "<C-b>zz")
vim.keymap.set({ "n", "v" }, "<C-f>", "<C-f>zz")

--window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

vim.keymap.set({ "n", "v" }, "<leader>ww", "<cmd>wincmd w<cr>", { desc = "Go to Next Window" })
vim.keymap.set({ "n", "v" }, "<leader>wd", "<cmd>wincmd c<cr>", { desc = "Close Current Window" })
vim.keymap.set({ "n", "v" }, "<leader>wx", "<cmd>wincmd x<cr>", { desc = "Swap Windows" })
vim.keymap.set({ "n", "v" }, "<leader>wv", "<cmd>wincmd v<cr>", { desc = "Split Window Vertically" })

-- vim.keymap.set("n", "J", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move line down" })
-- vim.keymap.set("n", "K", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move line up" })
vim.keymap.set("v", "J", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move line up" })

-- Easy lua execution
vim.keymap.set("n", "<leader>aa", ":.lua<CR>", { desc = "Execute lua" })
vim.keymap.set("v", "<leader>aa", ":lua<CR>", { desc = "Execute lua" })

if pcall(require, "snacks") then
	vim.keymap.set({ "n", "v" }, "<leader><leader>", function()
		require("snacks").picker.smart()
	end, { desc = "Smart Picker" })
end

if pcall(require, "grug-far") then
	vim.keymap.set({ "n", "v" }, "<leader>sr", function()
		require("grug-far").open()
	end, { desc = "Search and Replace" })
end

vim.keymap.set("n", "<leader>p", function()
	vim.pack.update()
end, { desc = "Pack Manager" })
vim.keymap.set({ "n", "v" }, "<leader>E", "<cmd>Yazi cwd<cr>", { desc = "Yazi at pwd" })
vim.keymap.set({ "n", "v" }, "<leader>e", "<cmd>Yazi<cr>", { desc = "Yazi at current buffer" })
vim.keymap.set("n", "<c-up>", "<cmd>Yazi toggle<cr>", { desc = "Resume the last yazi session" })

-- Flash
vim.keymap.set({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash" })
vim.keymap.set({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { desc = "Flash Treesitter" })
vim.keymap.set("o", "r", function()
	require("flash").remote()
end, { desc = "Remote Flash" })
vim.keymap.set({ "o", "x" }, "R", function()
	require("flash").treesitter_search()
end, { desc = "Treesitter Search" })

vim.keymap.set("n", "<leader>zz", function()
	require("custom.zen").toggle()
end, { desc = "Toggle Zen Mode" })

vim.keymap.set("n", "<leader>ts", function()
	require("custom.safemode").toggle()
end, { desc = "Toggle SAFE mode" })

-- Terminal: toggle a bottom split, and Esc to leave terminal-insert.
vim.keymap.set({ "n", "v", "t" }, "<C-/>", function()
	require("custom.terminal").toggle()
end, { desc = "Toggle terminal" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Enter normal mode in terminal" })

local ok_snacks, Snacks = pcall(require, "snacks")
if ok_snacks then
	vim.keymap.set({ "n", "v" }, "<leader>gd", function()
		Snacks.picker.lsp_definitions()
	end, { desc = "Goto Definition" })
	vim.keymap.set({ "n", "v" }, "<leader>gr", function()
		Snacks.picker.lsp_references()
	end, { desc = "Goto References" })
	vim.keymap.set({ "n", "v" }, "<leader>gI", function()
		Snacks.picker.lsp_implementations()
	end, { desc = "Goto Implementations" })
	vim.keymap.set({ "n", "v" }, "<leader>sk", function()
		Snacks.picker.keymaps()
	end, { desc = "Keymaps" })
	vim.keymap.set("n", "<leader>xx", function()
		Snacks.picker.diagnostics()
	end, { desc = "Diagnostics" })
end

local function diag_goto(next, severity)
	return function()
		vim.diagnostic.jump({
			count = (next and 1 or -1) * vim.v.count1,
			severity = severity and vim.diagnostic.severity[severity] or nil,
			float = true,
		})
	end
end
vim.keymap.set("n", "<leader>fc", function()
	if not vim.env.MYVIMRC then
		return vim.notify("No $MYVIMRC found!", vim.log.levels.WARN)
	end
	local current_root_dir = vim.uv.cwd()
	local config_dir = vim.fn.stdpath("config")
	vim.api.nvim_set_current_dir(config_dir)
	vim.cmd("Yazi cwd")
	vim.api.nvim_set_current_dir(current_root_dir or config_dir)
end, { desc = "Open Config" })

if pcall(require, "telescope") then
	--HACK: unrelated but use vim.fn.system to execute shell cmds
	if vim.fn.executable("rg") == 1 then
		vim.keymap.set({ "n", "v" }, "<leader>sg", "<cmd>Telescope live_grep<cr>")
	end
	if vim.fn.executable("fzf") == 1 then
		vim.keymap.set({ "n", "v" }, "<leader>ff", "<cmd>Telescope find_files<cr>")
		vim.keymap.set("n", "<leader>fm", function()
			local messages = vim.split(vim.fn.execute("messages"), "\n")
			require("telescope.builtin").live_grep({
				search_dirs = {},
				default_text = "",
				finder = require("telescope.finders").new_table({
					results = messages,
				}),
				sorter = require("telescope.config").values.generic_sorter({}),
			})
		end, { desc = "Messages" })
	end
end

---@type Util
local util = require("util")

if pcall(require, "undotree") then
	vim.keymap.set("n", "<leader>uu", function()
		require("undotree").open({
			command = "30vnew",
			title = "Undotree",
		})
	end, { desc = "Undotree" })
end

if vim.fn.executable("lazygit") == 1 then
	vim.keymap.set("n", "<leader>gg", function()
		local buf = vim.api.nvim_create_buf(false, true)
		util.create_popup_term_win(buf, "lazygit", 0.8, 0.8, { "lazygit" })
	end, { desc = "Open lazygit on cwd" })
end

vim.keymap.set({ "n", "v" }, "<leader>td", function()
	local new_config = not vim.diagnostic.config().virtual_lines
	vim.diagnostic.config({ virtual_lines = new_config })
end, { desc = "Toggle inline diagnostics" })
-- vim.keymap.set("n", "<leader>gg", function()
-- 	local width = math.floor(vim.o.columns * 0.8)
-- 	local height = math.floor(vim.o.lines * 0.8)
-- 	local row = math.floor((vim.o.lines - height) / 2)
-- 	local col = math.floor((vim.o.columns - width) / 2)
--
-- 	local buf = vim.api.nvim_create_buf(false, true) -- scratch buffer
--
-- 	-- print(vim.bo[bufnr].filetype(buf)
-- 	vim.api.nvim_open_win(buf, true, {
-- 		relative = "editor",
-- 		width = width,
-- 		height = height,
-- 		row = row,
-- 		col = col,
-- 		style = "minimal",
-- 		border = "rounded",
-- 		title = " lazygit ",
-- 		title_pos = "center",
-- 	})
--
-- 	-- local on_exit = function()
-- 	--   vim.api.nvim_buf_delete(buf, { force = true })
-- 	-- end
--
-- 	vim.fn.jobstart({ "lazygit" }, {
-- 		cwd = vim.fn.expand("%:p:h"),
-- 		detach = false,
-- 		-- on_stdout = on_exit, -- process exit with code : 0 will trigger when lazygit is exited which prints to stdout, so we trigger on_exit to automatically close the window
-- 		term = true,
-- 	})
-- 	vim.cmd("startinsert")
-- end, { desc = "Open lazygit" })

vim.keymap.set("n", "]e", diag_goto(true, "ERROR"), { desc = "Next Error" })
vim.keymap.set("n", "[e", diag_goto(false, "ERROR"), { desc = "Prev Error" })
vim.keymap.set("n", "]w", diag_goto(true, "WARN"), { desc = "Next Warning" })
vim.keymap.set("n", "[w", diag_goto(false, "WARN"), { desc = "Prev Warning" })

-- Buffers
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- LSP Specific
if vim.fn.has("nvim-0.12") == 1 then
	vim.keymap.set({ "n", "v" }, "<leader>fF", function()
		vim.lsp.buf.format()
	end, { desc = "LSP Format" })
end
-- nvim-treesitter-textobjects keymaps

--INFO: See https://github.com/nvim-treesitter/nvim-treesitter-textobjects/blob/main/BUILTIN_TEXTOBJECTS.md
-- Selects
local ok_select, select = pcall(require, "nvim-treesitter-textobjects.select")
if ok_select then
	vim.keymap.set({ "x", "o" }, "af", function()
		select.select_textobject("@function.outer", "textobjects")
	end, { desc = "function" })
	vim.keymap.set({ "x", "o" }, "if", function()
		select.select_textobject("@function.inner", "textobjects")
	end, { desc = "function" })
	vim.keymap.set({ "x", "o" }, "al", function()
		select.select_textobject("@loop.outer", "textobjects")
	end, { desc = "loop" })
	vim.keymap.set({ "x", "o" }, "il", function()
		select.select_textobject("@loop.inner", "textobjects")
	end, { desc = "loop" })
	vim.keymap.set({ "x", "o" }, "i1", function()
		select.select_textobject("@number.inner", "textobjects")
	end, { desc = "number" })
	vim.keymap.set({ "x", "o" }, "a/", function()
		select.select_textobject("@comment.outer", "textobjects")
	end, { desc = "comment" })
	vim.keymap.set({ "x", "o" }, "i/", function()
		select.select_textobject("@comment.outer", "textobjects")
	end, { desc = "comment" })
	vim.keymap.set({ "x", "o" }, "ac", function()
		select.select_textobject("@class.outer", "textobjects")
	end, { desc = "class" })
	vim.keymap.set({ "x", "o" }, "ic", function()
		select.select_textobject("@class.inner", "textobjects")
	end, { desc = "class" })
	vim.keymap.set({ "x", "o" }, "aa", function()
		select.select_textobject("@parameter.outer", "textobjects")
	end, { desc = "parameter" })
	vim.keymap.set({ "x", "o" }, "ia", function()
		select.select_textobject("@parameter.inner", "textobjects")
	end, { desc = "parameter" })
	vim.keymap.set({ "x", "o" }, "ao", function()
		select.select_textobject("@conditional.outer", "textobjects")
	end, { desc = "conditional" })
	vim.keymap.set({ "x", "o" }, "io", function()
		select.select_textobject("@conditional.inner", "textobjects")
	end, { desc = "conditional" })
	-- You can also use captures from other query groups like `locals.scm`
	-- vim.keymap.set({ "x", "o" }, "as", function()
	--   select.select_textobject("@local.scope", "locals")
	-- end, { desc = "scope" })

	-- Swaps
	local swap = require("nvim-treesitter-textobjects.swap")
	vim.keymap.set("n", "<leader>as", function()
		swap.swap_next("@parameter.inner")
	end, { desc = "Swap with next parameter" })
	vim.keymap.set("n", "<leader>aS", function()
		swap.swap_previous("@parameter.outer")
	end, { desc = "Swap with previous parameter" })

	local move = require("nvim-treesitter-textobjects.move")
	vim.keymap.set({ "n", "x", "o" }, "]f", function()
		move.goto_next_start("@function.outer", "textobjects")
	end, { desc = "Next function start" })
	vim.keymap.set({ "n", "x", "o" }, "]c", function()
		move.goto_next_start("@class.outer", "textobjects")
	end, { desc = "Next class start" })

	vim.keymap.set({ "n", "x", "o" }, "]1", function()
		move.goto_next_start("@number.inner", "textobjects")
	end, { desc = "Next number start" })
	-- You can also pass a list to group multiple queries.
	-- vim.keymap.set({ "n", "x", "o" }, "]o", function()
	--   move.goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects")
	-- end, { desc = "Next loop start" })
	-- You can also use captures from other query groups like `locals.scm` or `folds.scm`
	vim.keymap.set({ "n", "x", "o" }, "]s", function()
		move.goto_next_start("@local.scope", "locals")
	end, { desc = "Next scope start" })
	vim.keymap.set({ "n", "x", "o" }, "]z", function()
		move.goto_next_start("@fold", "folds")
	end, { desc = "Next fold start" })

	vim.keymap.set({ "n", "x", "o" }, "]/", function()
		move.goto_next_start("@comment.outer", "textobjects")
	end, { desc = "Next comment start" })

	vim.keymap.set({ "n", "x", "o" }, "]F", function()
		move.goto_next_end("@function.outer", "textobjects")
	end, { desc = "Next function end" })
	-- vim.keymap.set({ "n", "x", "o" }, "]A", function()
	--   move.goto_next_end("@parameter.outer", "textobjects")
	-- end, { desc = "Next parameter end" })
	vim.keymap.set({ "n", "x", "o" }, "]C", function()
		move.goto_next_end("@class.outer", "textobjects")
	end, { desc = "Next class end" })
	vim.keymap.set({ "n", "x", "o" }, "]|", function()
		move.goto_next_end("@comment.outer", "textobjects")
	end, { desc = "Next comment end" })

	vim.keymap.set({ "n", "x", "o" }, "[f", function()
		move.goto_previous_start("@function.outer", "textobjects")
	end, { desc = "Previous function start" })
	vim.keymap.set({ "n", "x", "o" }, "[c", function()
		move.goto_previous_start("@class.outer", "textobjects")
	end, { desc = "Previous class start" })
	vim.keymap.set({ "n", "x", "o" }, "[1", function()
		move.goto_previous_start("@number.inner", "textobjects")
	end, { desc = "Previous number start" })
	-- vim.keymap.set({ "n", "x", "o" }, "[a", function()
	--   move.goto_previous_start("@class.outer", "textobjects")
	-- end, { desc = "Next comment end" })

	vim.keymap.set({ "n", "x", "o" }, "[F", function()
		move.goto_previous_end("@function.outer", "textobjects")
	end, { desc = "Previous function end" })
	vim.keymap.set({ "n", "x", "o" }, "[C", function()
		move.goto_previous_end("@class.outer", "textobjects")
	end, { desc = "Previous class end" })

	-- Go to either the start or the end, whichever is closer.
	-- Use if you want more granular movements
	vim.keymap.set({ "n", "x", "o" }, "]o", function()
		move.goto_next("@conditional.outer", "textobjects")
	end, { desc = "Next conditional" })
	vim.keymap.set({ "n", "x", "o" }, "[o", function()
		move.goto_previous("@conditional.outer", "textobjects")
	end, { desc = "Previous conditional" })

	local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

	-- Repeat movement with ; and ,
	-- ensure ; goes forward and , goes backward regardless of the last direction
	vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next, { desc = "Repeat last move forward" })
	vim.keymap.set(
		{ "n", "x", "o" },
		",",
		ts_repeat_move.repeat_last_move_previous,
		{ desc = "Repeat last move backward" }
	)

	-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
	vim.keymap.set(
		{ "n", "x", "o" },
		"f",
		ts_repeat_move.builtin_f_expr,
		{ expr = true, desc = "Find next char (repeatable)" }
	)
	vim.keymap.set(
		{ "n", "x", "o" },
		"F",
		ts_repeat_move.builtin_F_expr,
		{ expr = true, desc = "Find prev char (repeatable)" }
	)
	vim.keymap.set(
		{ "n", "x", "o" },
		"t",
		ts_repeat_move.builtin_t_expr,
		{ expr = true, desc = "Till next char (repeatable)" }
	)
	vim.keymap.set(
		{ "n", "x", "o" },
		"T",
		ts_repeat_move.builtin_T_expr,
		{ expr = true, desc = "Till prev char (repeatable)" }
	)
end
