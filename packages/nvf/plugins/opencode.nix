# ≈ lua/plugins/opencode.lua
#
# No nvf module, so it comes in via vim.extraPlugins. Configuration is via the
# vim.g.opencode_opts global rather than a setup() call. `vim.o.autoread` — which the
# plugin's events.reload needs — is set in ../options.nix, and the <leader>o* / go /
# goo / <S-C-u> / <S-C-d> bindings are in ../keymaps.nix.
{ pkgs, ... }:
{
  config.vim.extraPlugins.opencode = {
    package = pkgs.vimPlugins.opencode-nvim;
    after = [ "tiny-inline-diagnostic" ];
    setup = ''
      ---@type opencode.Opts
      vim.g.opencode_opts = {}
    '';
  };
}
