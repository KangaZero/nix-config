{ inputs }:
args:
let
  mkNixOS = import ./mkNixOS.nix { inherit inputs; };
in
mkNixOS (
  args
  // {
    extraModules = (args.extraModules or [ ]) ++ [
      inputs.nixos-wsl.nixosModules.wsl
      ../modules/nixos/nix-ld.nix
      ../modules/nixos/graphics.nix
      ../modules/nixos/wayland/niri.nix
    ];
  }
)
