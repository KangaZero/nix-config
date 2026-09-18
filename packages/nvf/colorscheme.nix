# ≈ lua/colorscheme.lua
#
# nekonight is not in nvf's theme enum (vim.theme.name accepts ~10 upstream
# themes), but that enum is only a convenience — vim.theme.enable stays off and
# the colorscheme comes in through vim.extraPlugins instead, pinned to the same
# revision the real config's nvim-pack-lock.json uses.
{ pkgs, ... }:
let
  # Mirror of the removed upstream neko-night/nvim (nekonight colorscheme by
  # BrunoCiccarino, MIT), snapshot-preserved. Same rev as nvim-pack-lock.json so
  # both editors render identically.
  nekonight-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "nekonight.nvim";
    version = "0-unstable-37b542b";
    src = pkgs.fetchFromGitHub {
      owner = "KangaZero";
      repo = "nekonight.nvim";
      rev = "37b542b26eaf10524379bae75c590018f47a3613";
      hash = "sha256-ITPv/MlypLNFr4shYJtV8g0mtS7MMbeg7i2In4NDX5Q=";
    };
    # buildVimPlugin require-checks every Lua module. These two are optional extras
    # that pull in deps the colorscheme itself does not need, so they fail the check.
    nvimSkipModules = [
      "nekonight.extra.fzf"
      "nekonight.docs"
    ];
  };
in
{
  config.vim = {
    # nvf's theme module would issue its own colorscheme command and fight this.
    theme.enable = false;

    extraPlugins.nekonight = {
      package = nekonight-nvim;
      setup = ''
        require("nekonight").setup({
          style = "night",
          transparent = true,
          terminal_colors = true,
          styles = {
            sidebars = "transparent",
            floats = "transparent",
          },
          plugins = {
            all = false,
            auto = false,
            ["which-key"] = true,
          },
          on_highlights = function(highlights, colors)
            local prompt = "#2d3149"
            highlights.TelescopeNormal = { bg = colors.bg_dark, fg = colors.fg_dark }
            highlights.TelescopeBorder = { bg = colors.bg_dark, fg = colors.bg_dark }
            highlights.TelescopePromptNormal = { bg = prompt }
            highlights.TelescopePromptBorder = { bg = prompt, fg = prompt }
            highlights.TelescopePromptTitle = { bg = prompt, fg = prompt }
            highlights.TelescopePreviewTitle = { bg = colors.bg_dark, fg = colors.bg_dark }
            highlights.TelescopeResultsTitle = { bg = colors.bg_dark, fg = colors.bg_dark }
          end,
        })

        vim.cmd.colorscheme("nekonight-deep-ocean")

        vim.api.nvim_set_hl(0, "SpellBad", { undercurl = true, fg = "#f38ba8" })

        -- deep-ocean does not quite fit the wallpaper; nudge the separators and
        -- line numbers the same way the real config does.
        if vim.g.colors_name == "nekonight-deep-ocean" then
          vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#c099ff" })
          vim.api.nvim_set_hl(0, "CursorLine", { bg = "#232323" })
          vim.api.nvim_set_hl(0, "LineNr", { fg = "#767676" })
          vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#767676" })
          vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#767676" })
        end

        -- Pager highlights (eg. :messages)
        vim.api.nvim_set_hl(0, "MsgArea", { fg = "#cdd6f4", bg = "#1e1e2e" })
        vim.api.nvim_set_hl(0, "MsgSeparator", { fg = "#45475a", bg = "#1e1e2e" })
        vim.api.nvim_set_hl(0, "MoreMsg", { fg = "#a6e3a1", bold = true })
        vim.api.nvim_set_hl(0, "ErrorMsg", { fg = "#f38ba8", bold = true })
        vim.api.nvim_set_hl(0, "WarningMsg", { fg = "#f9e2af", bold = true })
        vim.api.nvim_set_hl(0, "Question", { fg = "#89b4fa", bold = true })
      '';
    };
  };
}
