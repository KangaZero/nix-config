{ inputs }:
{
  mkDarwin = import ./mkDarwin.nix { inherit inputs; };
  mkNixOS = import ./mkNixOS.nix { inherit inputs; };
  mkWSL = import ./mkWSL.nix { inherit inputs; };
  mkChecks = import ./mkChecks.nix { inherit inputs; };
  mkDevShell = import ./mkDevShell.nix { inherit inputs; };
}
