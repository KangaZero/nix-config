{
  pkgs,
  nvf,
}:
# Entry point — mirrors config/init.lua. nvf modules are nixpkgs-style modules
# (nvf.lib.neovimConfiguration calls lib.evalModules), so `imports` composes them
# the same way init.lua's require() calls do. Module order is irrelevant to Nix
# (options merge), but it is kept identical to init.lua so the two trees read alike.
#
# Built standalone rather than via the programs.nvf home-manager module: that module
# drops its package into home.packages as bin/nvim, which would collide with
# programs.neovim. mnw sets appName = "nvf", so state lands in ~/.config/nvf.
(nvf.lib.neovimConfiguration {
  inherit pkgs;

  modules = [
    ./core.nix
    ./lsp.nix
    ./plugins
    ./options.nix
    ./colorscheme.nix
    ./statusline.nix
    ./autocmds.nix
    ./keymaps.nix
  ];
}).neovim
