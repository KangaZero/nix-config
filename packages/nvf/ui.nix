{ pkgs, lib, ... }:
{
  config.vim = {
    ui = {
      ui2.enable = true;
      illuminate.enable = true;
      nvim-highlight-colors.enable = true;
    };
    visuals = {
      fidget-nvim.enable = true;
    };
    statusline.lualine = {
      enable = true;
      integrations.breadcrumbs = {
        lspsaga.enable = false;
      };
      setupOpts.options.theme =
        lib.generators.mkLuaInline # lua
          ''
            function()
              local style = (vim.g.colors_name or "nekonight-night"):gsub("^nekonight%-", "")
              local ok, theme = pcall(function()
                return require("lualine.themes._nekonight").get(style)
              end)
              if not ok then
                return "auto"
              end
              for _, mode in pairs(theme) do
                if mode.b then mode.b.bg = "NONE" end
                if mode.c then mode.c.bg = "NONE" end
              end
              if theme.inactive then
                for _, section in ipairs({ "a", "b", "c" }) do
                  if theme.inactive[section] then theme.inactive[section].bg = "NONE" end
                end
              end
              return theme
            end
          '';
    };
    extraPlugins.undo-glow = {
      package = pkgs.vimUtils.buildVimPlugin {
        pname = "undo-glow.nvim";
        version = "1.13.0";
        src = pkgs.fetchFromGitHub {
          owner = "y3owk1n";
          repo = "undo-glow.nvim";
          tag = "v1.13.0";
          hash = "sha256-TpZlObtK+tasaGEDuQBcs7QdHzcM7LAnKD2oficFEF0=";
        };
        meta = {
          homepage = "https://github.com/y3owk1n/undo-glow.nvim";
          license = lib.meta.getLicenseFromSpdxId "Apache-2.0";
          hydraPlatforms = [ ];
        };
      };
      # nvf's extraPluginType only exposes package / after / setup, and
      # `setup` is a raw Lua string appended to init.lua. There is no
      # lazy.nvim `keys` / `init` here, and undo-glow creates no keymaps
      # or autocmds by itself — so they are written out explicitly.
      setup =
        # lua
        ''
            local Util = require("nekonight.util")
            local colors = require("nekonight.colors").setup({ style = "deep-ocean" })
            local tint = function(color, amount)
                    return Util.blend_bg(color, amount, colors.bg)
            end
          require("undo-glow").setup({
            animation = {
              enabled = true,
              duration = 300,
              animation_type = "zoom",
              window_scoped = true,
            },
            highlights = {
                    undo = { hl_color = { bg = tint(colors.red, 0.25) } },
                    redo = { hl_color = { bg = tint(colors.green, 0.25) } },
                    yank = { hl_color = { bg = tint(colors.yellow, 0.25) } },
                    paste = { hl_color = { bg = tint(colors.cyan, 0.25) } },
                    search = { hl_color = { bg = tint(colors.purple, 0.25) } },
                    comment = { hl_color = { bg = tint(colors.orange, 0.25) } },
                    cursor = { hl_color = { bg = tint(colors.magenta, 0.25) } },
            },
            priority = 2048 * 3,
          })

          local map = vim.keymap.set

          map("n", "u", function()
            require("undo-glow").undo()
          end, { desc = "Undo with highlight" })

          map("n", "U", function()
            require("undo-glow").redo()
          end, { desc = "Redo with highlight" })

          map("n", "p", function()
            require("undo-glow").paste_below()
          end, { desc = "Paste below with highlight" })

          map("n", "P", function()
            require("undo-glow").paste_above()
          end, { desc = "Paste above with highlight" })

          map("n", "n", function()
            require("undo-glow").search_next({
              animation = { animation_type = "strobe" },
            })
          end, { desc = "Search next with highlight" })

          map("n", "N", function()
            require("undo-glow").search_prev({
              animation = { animation_type = "strobe" },
            })
          end, { desc = "Search prev with highlight" })

          map("n", "*", function()
            require("undo-glow").search_star({
              animation = { animation_type = "strobe" },
            })
          end, { desc = "Search star with highlight" })

          map("n", "#", function()
            require("undo-glow").search_hash({
              animation = { animation_type = "strobe" },
            })
          end, { desc = "Search hash with highlight" })

          map({ "n", "x" }, "gc", function()
            local pos = vim.fn.getpos(".")
            vim.schedule(function()
              vim.fn.setpos(".", pos)
            end)
            return require("undo-glow").comment()
          end, { expr = true, desc = "Toggle comment with highlight" })

          map("o", "gc", function()
            require("undo-glow").comment_textobject()
          end, { desc = "Comment textobject with highlight" })

          map("n", "gcc", function()
            return require("undo-glow").comment_line()
          end, { expr = true, desc = "Toggle comment line with highlight" })

          vim.api.nvim_create_autocmd("TextYankPost", {
            desc = "Highlight when yanking (copying) text",
            callback = function()
              require("undo-glow").yank()
            end,
          })

          vim.api.nvim_create_autocmd("CursorMoved", {
            desc = "Highlight when cursor moved significantly",
            callback = function()
              require("undo-glow").cursor_moved({
                animation = { animation_type = "slide" },
              })
            end,
          })

          vim.api.nvim_create_autocmd("FocusGained", {
            desc = "Highlight when focus gained",
            callback = function()
              ---@type UndoGlow.CommandOpts
              local opts = {
                animation = { animation_type = "slide" },
              }
              opts = require("undo-glow.utils").merge_command_opts("UgCursor", opts)
              local pos = require("undo-glow.utils").get_current_cursor_row()
              require("undo-glow").highlight_region(vim.tbl_extend("force", opts, {
                s_row = pos.s_row,
                s_col = pos.s_col,
                e_row = pos.e_row,
                e_col = pos.e_col,
                force_edge = opts.force_edge == nil and true or opts.force_edge,
              }))
            end,
          })

          vim.api.nvim_create_autocmd("CmdlineLeave", {
            desc = "Highlight when search cmdline leave",
            callback = function()
              require("undo-glow").search_cmd({
                animation = { animation_type = "fade" },
              })
            end,
          })
        '';
    };
  };
}
