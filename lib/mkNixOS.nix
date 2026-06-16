{ inputs }:
{ hostname, system, user, extraModules ? [ ] }:
let
  userMeta = import ../home/profiles/${user}/default.nix;
  username = userMeta.usernames.linux;
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (inputs.nixpkgs.lib.getName pkg) [
        "claude-code"
        "steam"
        "steam-unwrapped"
        "steam-run"
      ];
  };
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit inputs username hostname userMeta;
  };
  modules = [
    ../modules/shared/nix-settings.nix
    ../hosts/${hostname}/default.nix
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs username userMeta;
          assetsDir = ../assets/linux;
          isDarwin = false;
          isLinux = true;
        };
        users.${username} = import ../home/profiles/${user}/linux.nix;
      };
    }
    { nixpkgs = { inherit pkgs; }; }
    {
      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
      security.sudo.wheelNeedsPassword = false;
    }
  ] ++ extraModules;
}
