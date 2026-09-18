# ≈ lua/plugins/yazi.lua
#
# netrw is disabled via vim.globals in ../options.nix, matching the real config's
# workaround for https://github.com/mikavilpas/yazi.nvim/issues/802.
{
  config.vim.utility.yazi-nvim = {
    enable = true;
    setupOpts = {
      open_for_directories = false;
      keymaps.show_help = "<f1>";
    };
  };
}
