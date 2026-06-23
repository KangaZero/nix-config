{ inputs }:
{
  system,
  user,
}:
let
  userMeta = import ../home/profiles/${user}/default.nix;
  username = userMeta.usernames.linux;
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (inputs.nixpkgs.lib.getName pkg) [
        "claude-code"
      ];
  };
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = {
    inherit
      inputs
      username
      userMeta
      ;
    assetsDir = ../assets/linux;
    isDarwin = false;
    isLinux = true;
  };
  modules = [ ../home/profiles/${user}/linux.nix ];
}
