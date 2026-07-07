vim.pack.add({
	"https://github.com/nvimdev/dashboard-nvim",
	-- "https://github.com/amansingh-afk/milli.nvim", -- Not good for performance, but quite cool
})
local logo = [[
         .                  *.
       .*%0.                &&*.
     .*%%%00*               &&&&*.                                                     .*.
   .*%%%%%000*              &&&&&&*.                          ..*******.              .%@&'
 .*%%%%%%%00000             &&&&&&&&*.                 .*0&%%@@@@@@@@@@@&0^          *@@@&'
*00%%%%%%%000000.           &&&&&&&&&&*            o&@@@@%&00*^^^''''^^*0%&'       *@@@&
0000%%%%%%0000000*          &&&&&&&&&&&          '%@@%0^ .*.              &%000&&&&@@@@&&&0o
000000%%%%000000000.        &&&&&&&&&&&           0@*   0%@@0            *@@&&000%@@@0^^'
0000000%%%0000000000*       &&&&&&&&&&&                00*@@0          *&@%'    0@@@0                  *.
00000000%%000000000000      &&&&&&&&&&&               0 *@@%        .0%@@0'    0@@@0     *%&          &@%'
000000000%'000000000000.    &&&&&&&&&&&              ^ 0@@%'     .o&@@&^      0@@@0     *@@&  .*.    &@@0
0000000000 '000000000000.   &&&&&&&&&&&             .*&@@%'  .*0%@@&*'       *@@@0     *@@%  .0@%   0@@*
0000000000   '00000000000*  &&&&&&&&&&&            *0%@@@%%%@@@%0^          *@@@0     *@@%  *%@@%  *@@^
0000000000    '000000000000.&&&&&&&&&&&           @@@@@@@@@@@%0'           '@@@&     *@@%  &0%@@* *@%'
0000000000      000000000000%&&&&&&&&&&           0@@@^    '^00%@&o.       %@@%'    *@@@'.&^0@@% *@%'
0000000000       ^0000000000%%&&&&&&&&&          '@@%'          '0@@&'    &@@@'   .&@@@ 0&''@@@*o@&
0000000000        '000000000%%%%&&&&&&&         '@@%'            0@@@0   *@@@^  .00@@@0&0  %@@%0@0
0000000000          00000000%%%%%%&&&&&        '@@&           .0@@@@0   '@@@* .*0'&@@@%*  *@@@%@0
0000000000           '000000%%%%%%%%&&*        %@0        .*&%@@%&^     0@@&'0&^ ^@@@@^   &@@@@*
 ^00000000            '00000%%%%%%'.*.         *0'  .*00&%@@@&0*'       ^0@@%&^    0@@&    &@@%^
   ^000000              ^000%%%%% &@&0o.o0000&&%%@@@@%&0*^'              ^0^        ''     ''
     ^0000               '00%%%%% ^&&%%%%&&&&000*^^'
       ^00                '0%%%%'                 [@KangaZero]
         '                  ^''
         ]]

--
--
--
-- local logo = [[@KangaZero]]

-- local splash = require("milli").load({ splash = "fire" })
local plugin_count = #vim.pack.get()
require("dashboard").setup({
	theme = "hyper",
	hide = { statusline = false, tabline = true, winbar = true },
	config = {
		header = vim.split(logo, "\n"),
		-- header = splash.frames[1],
		shortcut = {
			{
				desc = " Purgatory Time",
				group = "DiagnosticHint",
				key = "f",
				action = "Telescope",
			},
			{ desc = " New Hell", group = "DiagnosticInfo", key = "n", action = "ene | startinsert" },
			{
				desc = " Nightmares",
				group = "DiagnosticWarn",
				key = "r",
				action = "",
			},
			{
				desc = " Config",
				group = "DiagnosticError",
				key = "c",
				action = function()
					require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
				end,
			},
			{ desc = " Theme", group = "Number", key = "t", action = "Telescope colorscheme" },
			{
				desc = " Abandon Hope",
				group = "Error",
				key = "q",
				action = function()
					local msgs = {
						"YOU THINK THERE IS AN EXIT?",
						"PURGATORY IS ETERNAL.",
						"ERROR: SOUL_BOUND_TO_VIM",
						"NICE TRY, MORTAL.",
					}
					math.randomseed(os.time())
					vim.notify(msgs[math.random(#msgs)], vim.log.levels.ERROR, {
						title = "QUIT ATTEMPT DETECTED",
						timeout = 5000,
					})
				end,
			},
		},
		project = {
			enable = true,
			limit = 8,
			icon = " ",
			label = "Recent Purgatories",
			action = function() end,
		},
		mru = { enable = true, limit = 10, label = "Past Sins", icon = "󱅠 " },
		packages = { enable = true },
		footer = function()
			return {
				"",
				"" .. plugin_count .. " PLUGINS INFECTED 󰯆 ",
				'"Y̶O̶U̶ ̶C̶A̶N̶ ̶N̶E̶V̶E̶R̶ ̶Q̶U̶I̶T̶.̶ ̶Y̶O̶U̶ ̶A̶R̶E̶ ̶H̶E̶R̶E̶ ̶F̶O̶R̶E̶V̶E̶R̶.̶"',
			}
		end,
	},
})
-- require("milli").dashboard({ splash = "fire", loop = true })
-- dependencies = { { "nvim-tree/nvim-web-devicons" } },
