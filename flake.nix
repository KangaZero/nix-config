{
  description = "KangaZero — unified nix-darwin + NixOS monorepo";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # INFO: Due to the increase attacks on registries (eg. npm, AUR), I use Determinate Systems' nixpkgs-weekly — mirrors nixpkgs-unstable with a 7-day cooldown
    # See: https://determinate.systems/posts/nixpkgs-cooldown/
    # You may replace with the actual registry above if you want to live dangerously
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    odysseus-nix = {
      url = "github:KangaZero/odysseus-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-barutsrb-tap = {
      url = "github:BarutSRB/homebrew-tap";
      flake = false;
    };
    homebrew-neomouse-tap = {
      url = "github:KangaZero/homebrew-neomouse";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      lib = import ./lib { inherit inputs; };
      darwinHostname = "samuelwaiweng";
      darwinUser = "KangaZero";
      darwinSystem = "aarch64-darwin";
      wslHostname = "nixos";
      wslUser = "KangaZero";
      wslSystem = "x86_64-linux";
    in
    {
      darwinConfigurations."${darwinHostname}" = lib.mkDarwin {
        hostname = darwinHostname;
        system = darwinSystem;
        user = darwinUser;
        inherit self;
      };

      nixosConfigurations."${wslHostname}" = lib.mkWSL {
        hostname = wslHostname;
        system = wslSystem;
        user = wslUser;
      };

      checks."${darwinSystem}".pre-commit-check = lib.mkChecks {
        system = darwinSystem;
        buildTarget = ".#darwinConfigurations.${darwinHostname}.system";
      };

      checks."${wslSystem}".pre-commit-check = lib.mkChecks {
        system = wslSystem;
        buildTarget = ".#nixosConfigurations.${wslHostname}.config.system.build.toplevel";
      };

      devShells."${darwinSystem}".default = lib.mkDevShell {
        system = darwinSystem;
        inherit self;
      };

      devShells."${wslSystem}".default = lib.mkDevShell {
        system = wslSystem;
        inherit self;
      };

      formatter."${darwinSystem}" = nixpkgs.legacyPackages."${darwinSystem}".nixfmt-tree;
      formatter."${wslSystem}" = nixpkgs.legacyPackages."${wslSystem}".nixfmt-tree;

      packages."${darwinSystem}".kitty = import ./packages/kitty.nix {
        pkgs = nixpkgs.legacyPackages."${darwinSystem}";
        inherit (inputs) nix-wrapper-modules;
        assetsDir = ./assets/mac;
      };
    };
}
