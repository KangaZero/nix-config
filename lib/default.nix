{ inputs }:
{
  mkDarwin = import ./mkDarwin.nix { inherit inputs; };
  mkNixOS = import ./mkNixOS.nix { inherit inputs; };
  mkWSL = import ./mkWSL.nix {
    inherit inputs;
    lib = inputs.nixpkgs.lib;
  };
  mkChecks = import ./mkChecks.nix { inherit inputs; };
  mkDevShell = import ./mkDevShell.nix { inherit inputs; };
}
