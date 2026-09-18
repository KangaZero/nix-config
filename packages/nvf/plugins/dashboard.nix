# ≈ lua/plugins/dashboard.lua
#
# The ASCII header lives in ../dashboard-logo.txt rather than inline: the art
# contains a `''` sequence, which would need escaping inside a Nix indented string.
# Reading it keeps the art byte-identical to the real config.
#
# `shortcut` and `footer` go over as mkLuaInline because their `action` fields are a
# mix of command strings and closures.
#
# Changed from the real config: the footer's plugin count came from `#vim.pack.get()`,
# and nvf has no vim.pack. It reports the mnw-managed runtime pack count instead.
{ lib, ... }:
{
  config.vim.dashboard.dashboard-nvim = {
    enable = true;
    setupOpts = {
      theme = "hyper";
      hide = {
        statusline = false;
        tabline = true;
        winbar = true;
      };

      config = {
        header = lib.splitString "\n" (builtins.readFile ../dashboard-logo.txt);

        shortcut =
          lib.generators.mkLuaInline # lua

            ''
              {
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
              }
            '';

        project =
          lib.generators.mkLuaInline # lua

            ''
              {
                enable = true,
                limit = 8,
                icon = " ",
                label = "Recent Purgatories",
                action = function() end,
              }
            '';

        mru = {
          enable = true;
          limit = 10;
          label = "Past Sins";
          icon = "󱅠 ";
        };

        packages.enable = true;

        footer =
          lib.generators.mkLuaInline # lua

            ''
              function()
                local count = #vim.api.nvim_get_runtime_file("pack/*/*/*", true)
                return {
                  "",
                  "" .. count .. " PLUGINS INFECTED 󰯆 ",
                  '"Y̶O̶U̶ ̶C̶A̶N̶ ̶N̶E̶V̶E̶R̶ ̶Q̶U̶I̶T̶.̶ ̶Y̶O̶U̶ ̶A̶R̶E̶ ̶H̶E̶R̶E̶ ̶F̶O̶R̶E̶V̶E̶R̶.̶"',
                }
              end
            '';
      };
    };
  };
}
