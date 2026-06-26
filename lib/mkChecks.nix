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
      entry = "${pkgs.writeShellScriptBin "check-author" ''
        while IFS=' ' read -r local_ref local_sha remote_ref remote_sha; do
          [ "$local_sha" = "0000000000000000000000000000000000000000" ] && continue

          if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
            commits=$(git rev-list "$local_sha" --not --remotes 2>/dev/null)
          else
            commits=$(git rev-list "$remote_sha..$local_sha" 2>/dev/null)
          fi

          [ -z "$commits" ] && continue

          while IFS= read -r commit; do
            while IFS= read -r author; do
              if [ "$author" != "samuelyongw@gmail.com" ]; then
                echo "Push rejected: $commit not authored by KangaZero <samuelyongw@gmail.com> (got: $author)"
                exit 1
              fi
            done <<< "$(git log -10 --format="%ae" "$commit")"

            while IFS= read -r committer; do
              if [ "$committer" != "samuelyongw@gmail.com" ]; then
                echo "Push rejected: $commit not committed by KangaZero <samuelyongw@gmail.com> (got: $committer)"
                exit 1
              fi
            done <<< "$(git log -10 --format="%ce" "$commit")"
          done <<< "$commits"
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
