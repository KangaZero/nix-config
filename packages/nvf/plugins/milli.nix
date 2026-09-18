# ≈ the commented milli.nvim entry in lua/plugins/dashboard.lua
#
# Not in nixpkgs, so it is hand-packaged the same way ../colorscheme.nix packages
# nekonight.
#
# Left un-setup deliberately, matching the real config: dashboard-nvim owns the start
# screen there, and milli's splash/dashboard entrypoints are commented out because two
# dashboards both render on VimEnter and conflict. The plugin is on the runtimepath so
# `require("milli")` works on demand.
{ pkgs, ... }:
{
  config.vim.extraPlugins.milli = {
    package = pkgs.vimUtils.buildVimPlugin {
      pname = "milli.nvim";
      version = "0-unstable-0027462";
      src = pkgs.fetchFromGitHub {
        owner = "amansingh-afk";
        repo = "milli.nvim";
        rev = "00274623b76a66356e31e1861360b269987a7f64";
        hash = "sha256-EtrBQH8vzBMUF/Wp7t46sb39RQSPyGZWT+HucPoRxVg=";
      };
    };
    after = [ "opencode" ];
    setup = "";
  };
}
