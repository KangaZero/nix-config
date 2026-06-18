{ inputs }:
{ system, buildTarget }:
let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in
inputs.git-hooks.lib.${system}.run {
  src = ./..;
  hooks = {
    nixfmt.enable = true;
    statix.enable = true;
    deadnix.enable = true;
    home-build = {
      enable = true;
      name = "system build";
      entry = "nix build --no-link --print-build-logs ${buildTarget}";
      language = "system";
      files = "\\.nix$";
      pass_filenames = false;
      stages = [ "pre-push" ];
    };
    nvim-lua-syntax = {
      enable = true;
      name = "neovim config lua syntax";
      entry = "${pkgs.bash}/bin/bash -c '${pkgs.neovim}/bin/nvim --clean --headless -l home/modules/common/neovim/config/scripts/check-syntax.lua </dev/null'";
      language = "system";
      files = "^home/modules/common/neovim/config/.*\\.lua$";
      pass_filenames = false;
    };
  };
}
