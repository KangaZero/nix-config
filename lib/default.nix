{ inputs }:
{
  mkDarwin = import ./mkDarwin.nix { inherit inputs; };
  mkNixOS = import ./mkNixOS.nix { inherit inputs; };
  mkWSL = import ./mkWSL.nix {
    inherit inputs;
    lib = inputs.nixpkgs.lib;
  };
  # Standalone home-manager config — use when no sudo access on the target host.
  # Exposes homeConfigurations.${username} so `nh home switch` / `home-manager switch` work without root.
  mkHome = import ./mkHome.nix { inherit inputs; };
  mkChecks = import ./mkChecks.nix { inherit inputs; };
  mkDevShell = import ./mkDevShell.nix { inherit inputs; };
}
