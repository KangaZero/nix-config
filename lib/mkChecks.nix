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
    check-author = {
      enable = true;
      name = "check git author";
      #%ae is the author's email, %ce is the committer's email
      entry = "${pkgs.writeShellScriptBin "check-author" ''
        bad_author=$(git log --format="%ae" 2>/dev/null | grep -v "samuelyongw@gmail.com")
        bad_comitter=$(git log --format="%ce" 2>/dev/null | grep -v "samuelyongw@gmail.com")
        if [ -n "$bad_author" ]; then
          echo "Push rejected: commits not authored by KangaZero <samuelyongw@gmail.com>:"
          echo "$bad_author" author(s) found
          exit 1
        fi
        if [ -n "$bad_comitter" ]; then
          echo "Push rejected: commits not comitted by KangaZero <samuelyongw@gmail.com>:"
          echo "$bad_comitter" comitter(s) found
          exit 1
        fi
      ''}";
      language = "system";
      pass_filenames = false;
      always_run = true;
      stages = [ "pre-push" ];
    };
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
