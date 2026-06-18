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
      entry = "${pkgs.writeShellScript "check-author" ''
        while IFS=" " read -r _local_ref local_sha _remote_ref remote_sha; do
          [ "$local_sha" = "0000000000000000000000000000000000000000" ] && continue
          if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
            range="$local_sha"
          else
            range="$remote_sha..$local_sha"
          fi
          bad=$(git log --format="%H %ae" "$range" | grep -v "samuelyongw@gmail.com")
          if [ -n "$bad" ]; then
            echo "Push rejected: commits not authored by KangaZero <samuelyongw@gmail.com>:"
            echo "$bad"
            exit 1
          fi
        done
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
