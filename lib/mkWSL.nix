{ lib, inputs }:
args:
let
  mkNixOS = import ./mkNixOS.nix { inherit inputs; };
in
mkNixOS (
  lib.recursiveUpdate args {
    extraModules = (args.extraModules or [ ]) ++ [
      inputs.nixos-wsl.nixosModules.wsl
      # NOTE: no graphics.nix here — nixos-wsl already sets hardware.graphics.enable,
      # so enable32Bit would really pull pkgsi686Linux.mesa into a CLI-only closure.
      # INFO: Commented out as not in use and to reduce bulid time
      # ../modules/nixos/wayland/niri.nix
      { security.sudo.wheelNeedsPassword = false; }
    ];
  }
)
