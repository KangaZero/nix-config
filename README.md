# nix-config

A unified Nix flake monorepo consolidating macOS (nix-darwin) and NixOS configurations into a single, multi-platform, multi-user setup.

## Supported Platforms

| Host | OS | Architecture | Status |
|---|---|---|---|
| `KangaZero` | macOS (nix-darwin) | aarch64-darwin | Migrating |
| `wsl` | NixOS WSL2 | x86_64-linux | Migrating |
| `server` | NixOS headless | x86_64/aarch64-linux | Planned |

## Quick Start

```sh
# macOS
darwin-rebuild switch --flake .#KangaZero

# NixOS WSL
sudo nixos-rebuild switch --flake .#wsl

# Run standalone kitty wrapper (macOS)
nix run .#kitty

# Enter dev shell (installs pre-commit hooks)
nix develop
```

## Repository Structure

```
nix-config/
├── flake.nix                         # Inputs + outputs via lib helpers only
├── lib/
│   ├── default.nix                   # Re-exports all helpers
│   ├── mkDarwin.nix                  # Builds darwinSystem + home-manager
│   ├── mkNixOS.nix                   # Builds nixosSystem (bare metal / VM / server)
│   ├── mkWSL.nix                     # Thin wrapper: mkNixOS + nixos-wsl + extras
│   ├── mkChecks.nix                  # Pre-commit checks per system
│   └── mkDevShell.nix                # Dev shell per system
│
├── hosts/
│   ├── KangaZero/default.nix         # macOS M4 — hostname, spotlight, shell aliases
│   ├── wsl/default.nix               # WSL2 — wsl opts, nix-ld, root nvim symlink
│   └── server/default.nix            # Headless — sshd, no GUI (future)
│
├── modules/
│   ├── darwin/                       # nix-darwin system modules
│   │   ├── homebrew.nix              # nix-homebrew + taps + trust
│   │   ├── settings.nix              # macOS system defaults
│   │   └── applications.nix          # Spotlight alias activation script
│   ├── nixos/                        # NixOS system modules
│   │   ├── nix-ld.nix                # programs.nix-ld (run generic linux binaries)
│   │   ├── graphics.nix              # hardware.graphics.enable32Bit (WSL / VM)
│   │   └── wayland/
│   │       ├── niri.nix              # programs.niri + xwayland (system level)
│   │       └── xrdp-i3.nix           # xrdp + i3 (X11 alternative)
│   └── shared/
│       └── nix-settings.nix          # experimental-features, registry, gc — both platforms
│
├── home/
│   ├── profiles/
│   │   └── samuel/
│   │       ├── default.nix           # User metadata: usernames, git identities, stateVersion
│   │       ├── darwin.nix            # Darwin home-manager entry point
│   │       └── linux.nix             # Linux home-manager entry point
│   └── modules/
│       ├── common/                   # Platform-agnostic (compiles on darwin + linux)
│       │   ├── git.nix               # Reads identities from userMeta
│       │   ├── direnv.nix
│       │   ├── firefox.nix           # Firefox Dev Edition + policies
│       │   ├── kitty.nix             # Tokyo Night Moon — bg image from assetsDir
│       │   ├── neovim.nix            # Sideloaded config
│       │   ├── packages/
│       │   │   ├── common.nix        # Shared: fzf, ripgrep, bat, eza, jq, btop,
│       │   │   │                     #   yazi, nodejs, rustup, python3, mise, just,
│       │   │   │                     #   claude-code, nerd-fonts, gh
│       │   │   └── ns-script.nix     # nix-search-tv shell wrapper
│       │   └── shell/
│       │       └── zsh-core.nix      # Shared zsh: completion, autosuggestion,
│       │                             #   syntaxHighlighting, history
│       ├── darwin/                   # macOS home-manager modules
│       │   ├── packages.nix          # _7zz, imagemagick, odysseus-dev, etc.
│       │   ├── shell.nix             # brew shellenv, mac aliases
│       │   ├── oh-my-posh.nix        # Prompt
│       │   ├── discord.nix
│       │   ├── zellij.nix            # zjstatus layout
│       │   ├── zoxide.nix
│       │   └── lazygit.nix
│       └── linux/                    # Linux home-manager modules
│           ├── packages.nix          # azure-cli, uv, openssh, wget, etc.
│           ├── bash.nix              # zsh trampoline
│           ├── shell.nix             # Catppuccin oh-my-zsh, WSL aliases
│           ├── weston.nix            # Weston compositor bridge (WSL)
│           └── wayland/
│               ├── niri/             # Niri KDL, rofi, noctalia, cliphist
│               └── i3/               # i3 + dunst + polybar (inactive alternative)
│
├── overlays/
│   └── zjstatus/                     # darwin-only overlay
├── packages/
│   └── kitty.nix                     # nix-wrapper-modules standalone kitty
├── assets/
│   ├── mac/                          # macOS assets (background gif, etc.)
│   └── linux/                        # Linux assets (wallpapers, etc.)
├── .envrc                            # direnv: use flake .
├── .gitignore
└── .github/
    └── workflows/
        └── ci.yml                    # Matrix CI: lint + dry-build per architecture
```

---

## Dev Shell & Pre-commit Hooks

```sh
nix develop        # enters dev shell and installs pre-commit hooks
nix fmt            # format all .nix files with nixfmt-tree
```

Pre-commit hooks run on every commit:
- `deadnix` — remove dead Nix code
- `nixfmt` — format with nixfmt-tree
- `statix` — lint for anti-patterns

Pre-push hook per platform:
- **darwin** — `nix build .#darwinConfigurations.KangaZero.system`
- **linux** — `nix build .#nixosConfigurations.wsl.config.system.build.toplevel`

`.envrc` wires direnv so `nix develop` is entered automatically on `cd`.

---

## CI Pipeline

GitHub Actions runs a matrix across both architectures on every push and PR:

| Job | Runner | Checks |
|---|---|---|
| `check-darwin` | `macos-latest` (aarch64) | `nix flake check`, nixfmt, statix, deadnix, `darwin-rebuild build .#KangaZero` |
| `check-linux` | `ubuntu-latest` (x86_64) | `nix flake check`, nixfmt, statix, deadnix, `nix build .#nixosConfigurations.wsl.config.system.build.toplevel` |

Uses `DeterminateSystems/nix-installer-action` for fast Nix setup on both runners.

---

## Design Principles

### Clean flake.nix
`flake.nix` only declares inputs and calls lib helpers. No inline modules, no `let primaryUser = ...` blocks.

```nix
darwinConfigurations."KangaZero" = lib.mkDarwin {
  hostname = "KangaZero";
  system   = "aarch64-darwin";
  user     = "samuel";          # logical key — resolves to OS username inside lib
};

nixosConfigurations."wsl" = lib.mkWSL {
  hostname = "wsl";
  system   = "x86_64-linux";
  user     = "samuel";
};
```

### User profiles
One directory per real person in `home/profiles/`. All platform-specific details (OS username, UID/GID, git identities) live in `default.nix` for that person. The lib helpers resolve the right OS username automatically.

```nix
# home/profiles/samuel/default.nix
{
  fullName = "Samuel Wai Weng Yong";
  usernames = {
    darwin = "samuelwaiwengyong";
    linux  = "KangaZero";
  };
  darwinUid = 501;
  darwinGid = 20;
  git = {
    personal = { name = "KangaZero";           email = "samuelyongw@gmail.com"; };
    work     = { name = "Yong, Samuel Wai Weng"; email = "samuelwaiweng.yong@accenture.com"; };
  };
  stateVersion = "26.11";
}
```

To add a second user: create `home/profiles/alice/default.nix` with their metadata and add `user = "alice"` to the relevant host entry in `flake.nix`. No other changes needed.

### Core (shared) config
`modules/shared/nix-settings.nix` and `home/modules/common/` are the "core" — they run identically on every platform. Anything that would need a platform guard (`lib.mkIf pkgs.stdenv.isDarwin`) does not belong there; it goes into `modules/darwin/` or `modules/nixos/` instead.

### Platform dispatch — no guards inside modules
Platform selection happens at the profile entry point (`darwin.nix` imports darwin modules, `linux.nix` imports linux modules). Individual modules stay dumb — they never contain `lib.mkIf pkgs.stdenv.isDarwin`. This makes modules easier to reason about and test in isolation.

### specialArgs threading
Every home-manager module receives via `extraSpecialArgs`:

| Arg | Description |
|---|---|
| `inputs` | All flake inputs |
| `username` | OS-level username for this platform |
| `userMeta` | Full profile attrset from `home/profiles/<user>/default.nix` |
| `assetsDir` | Path to `assets/mac` or `assets/linux` |
| `isDarwin` / `isLinux` | Boolean flags for edge cases only |

---

## Adding a New Host

1. Create `hosts/<hostname>/default.nix` with host-specific settings
2. Add an entry to `flake.nix`:
   ```nix
   # macOS
   darwinConfigurations."<hostname>" = lib.mkDarwin {
     hostname = "<hostname>";
     system   = "aarch64-darwin";
     user     = "samuel";
   };

   # NixOS bare metal
   nixosConfigurations."<hostname>" = lib.mkNixOS {
     hostname = "<hostname>";
     system   = "x86_64-linux";
     user     = "samuel";
   };
   ```
3. For bare metal NixOS, add a `hosts/<hostname>/hardware.nix` generated by `nixos-generate-config`

---

## Adding a New User

1. Create `home/profiles/<username>/default.nix` with their metadata
2. Create `home/profiles/<username>/darwin.nix` and/or `linux.nix` with their module imports
3. Add them to the relevant host entry in `flake.nix`

---

## Module Migration Plan

This repo consolidates two existing configs:
- `~/.config/nix` — macOS/nix-darwin
- `~/Documents/wsl-nix-config` — NixOS WSL2

### Shared modules (merged into `home/modules/common/`)

| Module | Source | Notes |
|---|---|---|
| `git.nix` | Both | WSL settings (autocrlf, lfs, rebase) + mac settings (github.user); identity from `userMeta.git` |
| `direnv.nix` | Both | WSL version used (adds `enableBashIntegration = true`, harmless on darwin) |
| `firefox.nix` | Both | Nearly identical policies; canonical pref values chosen |
| `kitty.nix` | Both | Shared Tokyo Night Moon palette; `background_image = "${assetsDir}/kitty-bg"` |
| `neovim.nix` | WSL only | Sideloaded config; imported on both platforms going forward |

### Platform-specific modules

| Module | Platform | Source |
|---|---|---|
| `oh-my-posh.nix`, `zellij.nix`, `discord.nix`, `lazygit.nix`, `zoxide.nix` | darwin | mac config |
| `shell.nix` (oh-my-posh, brew shellenv) | darwin | mac config |
| `wayland/niri/` | linux | WSL config |
| `wayland/i3/` | linux | WSL config (inactive) |
| `bash.nix`, `weston.nix` | linux | WSL config |
| `shell.nix` (catppuccin, WSL aliases) | linux | WSL config |

### packages split

Common subset extracted to `home/modules/common/packages/common.nix`:
`fzf`, `ripgrep`, `bat`, `eza`, `curl`, `jq`, `btop`, `yazi`, `fd`, `nodejs`, `pnpm`, `rustup`, `python3`, `mise`, `just`, `claude-code`, `nerd-fonts.jetbrains-mono`, `gh`

Platform-only packages stay in `home/modules/darwin/packages.nix` and `home/modules/linux/packages.nix`.

---

## Migration Steps

- [x] **Step 1** — README and repo structure plan (this commit)
- [ ] **Step 2** — Scaffold: create all directories and stub files; verify `nix flake check`
- [ ] **Step 3** — Migrate darwin: port mac config; verify `darwin-rebuild build .#KangaZero`
- [ ] **Step 4** — Migrate NixOS/WSL: port WSL config; verify `nix build .#nixosConfigurations.wsl.config.system.build.toplevel`
- [ ] **Step 5** — Merge shared modules: consolidate `common/`; verify both builds pass
- [ ] **Step 6** — Archive old repos

## Verification

```sh
darwin-rebuild build --flake .#KangaZero
nix build .#nixosConfigurations.wsl.config.system.build.toplevel
nix run .#kitty
nix flake check
```
