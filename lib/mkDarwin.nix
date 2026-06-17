{ inputs }:
{
  hostname,
  system,
  user,
  self ? null,
}:
let
  userMeta = import ../home/profiles/${user}/default.nix;
  username = userMeta.usernames.darwin;
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (inputs.nixpkgs.lib.getName pkg) [
        "claude-code"
        "7zz"
        "discord"
      ];
    overlays = [ (import ../overlays/zjstatus { inherit inputs; }) ];
  };
in
inputs.darwin.lib.darwinSystem {
  inherit system;
  specialArgs = {
    inherit
      inputs
      username
      hostname
      userMeta
      ;
  }
  // (if self != null then { inherit self; } else { });
  modules = [
    ../modules/shared/nix-settings.nix
    ../modules/darwin/homebrew.nix
    ../modules/darwin/settings.nix
    ../modules/darwin/applications.nix
    ../hosts/${hostname}/default.nix
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs username userMeta;
          assetsDir = ../assets/mac;
          isDarwin = true;
          isLinux = false;
        };
        users.${username} = import ../home/profiles/${user}/darwin.nix;
      };
    }
    { nixpkgs = { inherit pkgs; }; }
    {
      system.primaryUser = username;
      users.users.${username} = {
        name = username;
        description = userMeta.fullName;
        home = "/Users/${username}";
        shell = pkgs.zsh;
        uid = userMeta.darwinUid;
        gid = userMeta.darwinGid;
      };
      environment = {
        systemPackages = [ pkgs.mkalias ];
        systemPath = [ "/opt/homebrew/bin" ];
        pathsToLink = [ "/Applications" ];
      };
    }
  ];
}
