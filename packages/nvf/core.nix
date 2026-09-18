# ≈ lua/core.lua — treesitter and the always-on editing primitives.
{
  config.vim = {
    # `nvim` belongs to programs.neovim. Nothing here may claim vi/vim.
    viAlias = false;
    vimAlias = false;

    treesitter = {
      enable = true;
      fold = true;
      textobjects.enable = true;
    };

    ui.nvim-highlight-colors.enable = true;
  };
}
