{ inputs }:
{ system, buildTarget }:
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
  };
}
