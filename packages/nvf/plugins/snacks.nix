# ≈ lua/plugins/snacks.lua
{
  config.vim.utility.snacks-nvim = {
    enable = true;
    setupOpts = {
      bigfile.enabled = true;
      # dashboard-nvim + milli own the start screen. Two dashboards both render on
      # VimEnter and conflict.
      dashboard.enabled = false;
      explorer.enabled = false;
      indent.enabled = true;
      input.enabled = true;
      picker.enabled = true;
      notifier.enabled = true;
      quickfile.enabled = true;
      scope.enabled = true;
      scroll.enabled = true;
      statuscolumn.enabled = true;
      words.enabled = true;
    };
  };
}
