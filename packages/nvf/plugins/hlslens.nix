# ≈ lua/plugins/hlslens.lua
#
# No nvf module, so it comes in via vim.extraPlugins. The n/N/*/#/g*/g# bindings that
# call hlslens.start() live in ../keymaps.nix.
{ pkgs, ... }:
{
  config.vim.extraPlugins.hlslens = {
    package = pkgs.vimPlugins.nvim-hlslens;
    setup = ''require("hlslens").setup({})'';
  };
}
