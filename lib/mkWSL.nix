{ lib, inputs }:
args:
let
  mkNixOS = import ./mkNixOS.nix { inherit inputs; };
in
mkNixOS (
  lib.recursiveUpdate args {
    extraModules = (args.extraModules or [ ]) ++ [
      inputs.nixos-wsl.nixosModules.wsl
      # INFO: nix-ld allows to run unpatched dynamic binaries on NixOS
      ../modules/nixos/nix-ld.nix
      ../modules/nixos/graphics.nix
      ../modules/nixos/wayland/niri.nix
      { security.sudo.wheelNeedsPassword = false; }
    ];
  }
)
