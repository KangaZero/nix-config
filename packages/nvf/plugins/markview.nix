# ≈ lua/plugins/markview.lua
#
# markview is reached through the markdown language module rather than a standalone
# option. The real config only does vim.pack.add with no setup call.
{
  config.vim.languages.markdown = {
    enable = true;
    extensions.markview-nvim.enable = true;
  };
}
