# ≈ lua/plugins/which-key.lua
#
# The real config's setup block is entirely commented out, so which-key runs on its
# defaults there. Only the `modern` preset is set here to match the intent recorded
# in that commented block.
{
  config.vim.binds.whichKey = {
    enable = true;
    setupOpts.preset = "modern";
  };
}
