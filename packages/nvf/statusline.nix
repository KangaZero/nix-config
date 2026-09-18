# ≈ lua/ui/statusline.nix
#
# nvf ships lualine only; the hand-written statusline has no option path. lualine
# stands in rather than embedding 81 lines of Lua for no declarative gain.
# theme = "auto" so it derives from nekonight instead of hardcoding a palette.
{
  config.vim.statusline.lualine = {
    enable = true;
    setupOpts.options.theme = "auto";
  };
}
