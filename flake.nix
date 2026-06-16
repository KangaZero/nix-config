{
  description = "KangaZero — unified nix-darwin + NixOS monorepo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

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
    { self, nixpkgs, git-hooks, ... }@inputs:
    let
      lib = import ./lib { inherit inputs; };
    in
    {
      darwinConfigurations."KangaZero" = lib.mkDarwin {
        hostname = "KangaZero";
        system = "aarch64-darwin";
        user = "samuel";
      };

      nixosConfigurations."wsl" = lib.mkWSL {
        hostname = "wsl";
        system = "x86_64-linux";
        user = "samuel";
      };

      checks."aarch64-darwin".pre-commit-check = lib.mkChecks {
        system = "aarch64-darwin";
        buildTarget = ".#darwinConfigurations.KangaZero.system";
      };

      checks."x86_64-linux".pre-commit-check = lib.mkChecks {
        system = "x86_64-linux";
        buildTarget = ".#nixosConfigurations.wsl.config.system.build.toplevel";
      };

      devShells."aarch64-darwin".default = lib.mkDevShell {
        system = "aarch64-darwin";
        inherit self;
      };

      devShells."x86_64-linux".default = lib.mkDevShell {
        system = "x86_64-linux";
        inherit self;
      };

      formatter."aarch64-darwin" = nixpkgs.legacyPackages."aarch64-darwin".nixfmt-tree;
      formatter."x86_64-linux" = nixpkgs.legacyPackages."x86_64-linux".nixfmt-tree;

      packages."aarch64-darwin".kitty = import ./packages/kitty.nix {
        pkgs = nixpkgs.legacyPackages."aarch64-darwin";
        inherit (inputs) nix-wrapper-modules;
        assetsDir = ./assets/mac;
      };
    };
}
