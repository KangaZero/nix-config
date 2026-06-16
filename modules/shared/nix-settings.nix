{ inputs, ... }:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    allow-dirty-locks = false;
    channel.enable = false;
    registry.nixpkgs.flake = inputs.nixpkgs;
  };
}
