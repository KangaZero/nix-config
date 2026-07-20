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
      # url = "github:nix-darwin/nix-darwin/a1fa429e945becaf60468600daf649be4ba0350c";
      # Commit 320cbf5 (July 4, 2026) changed the manual build to use --sidebar-depth instead of the old --toc-depth/--chunk-toc-depth flags, to match a nixpkgs PR (nixos/nixpkgs#537810) that renamed the nixos-render-docs CLI. Your nixpkgs pin doesn't have that nixpkgs PR yet, so its nixos-render-docs still only understands the old flags — hence "unrecognized arguments: --sidebar-depth."
      #TODO add back when matches nixpkgs
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

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
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
      darwinHostname = "KangaZero";
      darwinUser = "KangaZero";
      darwinSystem = "aarch64-darwin";
      wslHostname = "nixos";
      wslUser = "KangaZero";
      wslSystem = "x86_64-linux";
      serverHostname = "server";
      serverUser = "server";
      serverSystem = "x86_64-linux";
      # Standalone home-manager output key / activation target for the server host.
      # Distinct from serverUser ("server", the profile dir): the resolved Linux username
      # is "KangaZero" (userMeta.usernames.linux), so `home-manager switch --flake .#KangaZero`.
      serverHomeManagerUser = "KangaZero";
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

      # Bare-metal NixOS laptop. mkWSL is just mkNixOS + WSL extraModules, so the
      # server calls mkNixOS directly with the non-WSL subset (nix-ld + graphics +
      # niri), skipping nixos-wsl and passwordless sudo.
      nixosConfigurations."${serverHostname}" = lib.mkNixOS {
        hostname = serverHostname;
        system = serverSystem;
        user = serverUser;
        # NOTE: path literals resolve relative to *this* file (repo root), so `./modules`.
        # mkWSL.nix uses `../modules` only because that literal lives in lib/.
        extraModules = [
          ./modules/nixos/nix-ld.nix
          ./modules/nixos/graphics.nix
          ./modules/nixos/wayland/niri.nix
        ];
      };

      checks =
        nixpkgs.lib.recursiveUpdate
          {
            "${darwinSystem}".pre-commit-check = lib.mkChecks {
              system = darwinSystem;
              buildTarget = ".#darwinConfigurations.${darwinHostname}.system";
            };

            # WSL host. The `server` host is bare-metal NixOS but shares the same
            # system (x86_64-linux), so both can't expose a `pre-commit-check`
            # under one system key. If the server shares WSL's arch, add its check
            # here under a distinct name; if it ever moves to a different arch it
            # gets its own system entry below instead.
            "${wslSystem}" = {
              pre-commit-check = lib.mkChecks {
                system = wslSystem;
                buildTarget = ".#nixosConfigurations.${wslHostname}.config.system.build.toplevel";
              };
            }
            // (
              if serverSystem == wslSystem then
                {
                  server-pre-commit-check = lib.mkChecks {
                    system = serverSystem;
                    buildTarget = ".#nixosConfigurations.${serverHostname}.config.system.build.toplevel";
                  };
                }
              else
                { }
            );
          }
          (
            if serverSystem != wslSystem then
              {
                "${serverSystem}".pre-commit-check = lib.mkChecks {
                  system = serverSystem;
                  buildTarget = ".#nixosConfigurations.${serverHostname}.config.system.build.toplevel";
                };
              }
            else
              { }
          );

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

      # Standalone home-manager for the bare-metal `server` host. Lets `home-manager switch`
      # apply home-only changes fast, without sudo/nixos-rebuild. Loads home/profiles/server/linux.nix
      # (user = serverUser = "server"); username resolves to "KangaZero" from userMeta, so the
      # output key + activation target is `KangaZero`. System daemons (greetd/pipewire/cups/fonts)
      # still require `nixos-rebuild switch`.
      #
      #   home-manager switch --flake .#${serverHomeManagerUser}
      homeConfigurations."${serverHomeManagerUser}" = lib.mkHome {
        system = serverSystem;
        user = serverUser;
        hostname = serverHostname;
      };

      # macOS only — Linux kitty is pkgs.kitty from nixpkgs.
      # Darwin needs a custom .app bundle via nix-wrapper-modules: bakes in theme (Tokyo Night Moon),
      # font (JetBrains Mono), animated GIF background, and transparency settings at the derivation
      # level so macOS Spotlight/Finder see a proper .app and the assets are store-pinned.
      packages."${darwinSystem}".kitty = import ./packages/kitty.nix {
        pkgs = nixpkgs.legacyPackages."${darwinSystem}";
        inherit (inputs) nix-wrapper-modules;
        assetsDir = ./assets/mac;
      };
    };
}
