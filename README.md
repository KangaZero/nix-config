# nix-config

A unified Nix flake monorepo consolidating macOS (nix-darwin) and NixOS configurations into a single, multi-platform, multi-user setup.

## Supported Platforms

| Host | OS | Architecture | Status |
|---|---|---|---|
| `samuelwaiweng` | macOS (nix-darwin) | aarch64-darwin | Migrating |
| `nixos` | NixOS WSL2 | x86_64-linux | Migrated |
| `server` | NixOS headless | x86_64/aarch64-linux | Planned |

## Nixpkgs Source

This repo uses [`DeterminateSystems/nixpkgs-weekly`](https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1) — a mirror of `nixpkgs-unstable` with a **7-day cooldown** before adopting new commits.

This guards against malicious packages reaching users before detection, a growing concern following supply-chain attacks on registries like npm and the AUR. See [the announcement](https://determinate.systems/posts/nixpkgs-cooldown/) for details.

To use raw `nixpkgs-unstable` instead, swap the input in `flake.nix`:

```nix
nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
```

---

## Setup & Usage

> **Repo location expected by shell aliases:** `~/.config/nix-config`

---

### macOS — nix-darwin (aarch64-darwin)

**Prerequisites:** Apple Silicon Mac.

**1. Install Nix (Determinate Systems — recommended)**

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

> This config sets `nix.enable = false` — it works with the Determinate installer instead of a nix-darwin-managed daemon. Do not use the official `sh.nixos.org` installer.
>
> macOS system updates can silently remove the `/nix` store. The Determinate installer handles re-mounting and persistence through OS upgrades. See [Nix disappeared from macOS](https://docs.determinate.systems/troubleshooting/nix-disappeared-from-macos/).

**2. Clone the repo**

```sh
git clone https://github.com/KangaZero/nix-config ~/.config/nix-config
cd ~/.config/nix-config
```

**3. First-time bootstrap** (nix-darwin not yet installed)

```sh
nix run nix-darwin/master -- switch --flake .#samuelwaiweng
```

**4. Day-to-day rebuilds**

```sh
# Shell aliases set by this config (work from anywhere):
nix-switch   # sudo darwin-rebuild switch --flake ~/.config/nix-config#samuelwaiweng
nix-build    # darwin-rebuild build   --flake ~/.config/nix-config#samuelwaiweng

# Directly from the repo:
darwin-rebuild switch --flake .#samuelwaiweng
```

**5. Dry-run / build check (no activation)**

```sh
darwin-rebuild build --flake .#samuelwaiweng
```

**6. Roll back** the last activation if something breaks

```sh
sudo darwin-rebuild switch --rollback
```

---

### NixOS WSL2 (x86_64-linux)

**Prerequisites:** Windows 10/11 with WSL2 enabled.

**1. Import NixOS-WSL**

Download the latest tarball from [github.com/nix-community/NixOS-WSL/releases](https://github.com/nix-community/NixOS-WSL/releases), then in PowerShell (admin):

```powershell
wsl --install --no-distribution
wsl --import NixOS "$env:LOCALAPPDATA\NixOS" nixos-wsl.tar.gz --version 2
wsl -d NixOS
```

**2. Clone the repo inside NixOS WSL**

```sh
nix-shell -p git --run "git clone https://github.com/KangaZero/nix-config ~/.config/nix-config"
cd ~/.config/nix-config
```

**3. First-time activation**

```sh
sudo nixos-rebuild switch --flake .#wsl
```

Restart the instance after the first switch so shell and user settings take effect:

```powershell
wsl --terminate NixOS && wsl -d NixOS
```

**4. Day-to-day rebuilds**

```sh
sudo nixos-rebuild switch --flake ~/.config/nix-config#wsl
# or from inside the repo:
sudo nixos-rebuild switch --flake .#wsl
```

**5. Dry-run / build check (no activation)**

```sh
nix build .#nixosConfigurations.nixos.config.system.build.toplevel
```

**6. Roll back** if something breaks

```sh
sudo nixos-rebuild switch --rollback
# or pick a specific generation:
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
sudo nixos-rebuild switch --profile /nix/var/nix/profiles/system-<N>-link
```

---

### NixOS bare metal / VM (x86_64-linux or aarch64-linux)

**Prerequisites:** NixOS minimal ISO booted, target partitions mounted at `/mnt`.

**1. Partition and mount** (example — adjust to your disk)

```sh
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart primary ext4 512MiB 100%
mkfs.fat -F32 /dev/nvme0n1p1 && mkfs.ext4 /dev/nvme0n1p2
mount /dev/nvme0n1p2 /mnt && mkdir -p /mnt/boot && mount /dev/nvme0n1p1 /mnt/boot
```

**2. Generate hardware config**

```sh
nixos-generate-config --root /mnt
```

**3. Clone the repo and add the hardware config**

```sh
nix-shell -p git --run "git clone https://github.com/KangaZero/nix-config /mnt/home/KangaZero/.config/nix-config"
cp /mnt/etc/nixos/hardware-configuration.nix \
   /mnt/home/KangaZero/.config/nix-config/hosts/<hostname>/hardware.nix
```

**4. Register the host in `flake.nix`**

```nix
nixosConfigurations."<hostname>" = lib.mkNixOS {
  hostname = "<hostname>";
  system   = "x86_64-linux";   # or "aarch64-linux"
  user     = "KangaZero";
};
```

**5. Install**

```sh
sudo nixos-install --flake /mnt/home/KangaZero/.config/nix-config#<hostname> --root /mnt
reboot
```

**6. Day-to-day rebuilds**

```sh
sudo nixos-rebuild switch --flake ~/.config/nix-config#<hostname>
```

**7. Roll back**

```sh
sudo nixos-rebuild switch --rollback
```

---

### NixOS server / headless (x86_64-linux)

Same flow as bare metal above but reference `hosts/server/default.nix` (sshd enabled, no GUI). Register in `flake.nix`:

```nix
nixosConfigurations."server" = lib.mkNixOS {
  hostname = "server";
  system   = "x86_64-linux";
  user     = "KangaZero";
};
```

Rebuild remotely after install:

```sh
nixos-rebuild switch --flake .#server --target-host user@server --use-remote-sudo
```

---

### Rebuild quick reference

| Platform | Command |
|---|---|
| macOS — switch | `darwin-rebuild switch --flake .#samuelwaiweng` |
| macOS — alias | `nix-switch` |
| macOS — build only | `darwin-rebuild build --flake .#samuelwaiweng` |
| macOS — rollback | `sudo darwin-rebuild switch --rollback` |
| NixOS WSL — switch | `sudo nixos-rebuild switch --flake .#wsl` |
| NixOS WSL — build only | `nix build .#nixosConfigurations.nixos.config.system.build.toplevel` |
| NixOS WSL/bare — rollback | `sudo nixos-rebuild switch --rollback` |
| NixOS server — remote | `nixos-rebuild switch --flake .#server --target-host user@host --use-remote-sudo` |
| kitty wrapper | `nix run .#kitty` |

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
│   │       └── niri.nix              # programs.niri + xwayland (system level)
│   └── shared/
│       └── nix-settings.nix          # experimental-features, registry, gc — both platforms
│
├── home/
│   ├── profiles/
│   │   └── KangaZero/
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
│               └── niri/             # Niri KDL, rofi, noctalia
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

## Safety & Checks

This repo is set up to catch problems as early as possible — before a commit, before a push, and in CI — so a broken config never makes it to activation.

### Layers of safety

| When | What runs | What it catches |
|---|---|---|
| On `cd` | `direnv` + `nix develop` | Activates dev shell automatically via `.envrc` |
| On every commit | `deadnix`, `nixfmt`, `statix` | Dead code, formatting drift, anti-patterns |
| On every push | `nix build` for the current platform | Broken builds before they reach the remote |
| On every PR / push to remote | Full CI matrix (both arches) | Cross-platform regressions |
| Any time manually | `nix flake check` | Full evaluation + checks for all outputs |

### Dev shell & pre-commit hooks

```sh
cd ~/.config/nix-config
nix develop        # enter dev shell; installs pre-commit hooks on first run
nix fmt            # format all .nix files with nixfmt-tree
```

`.envrc` means `nix develop` is entered automatically on `cd` — the hooks install themselves once and stay active.

Pre-commit hooks (block the commit if they fail):

| Hook | What it does |
|---|---|
| `deadnix` | Removes dead Nix code (unused bindings, unused imports) |
| `nixfmt` | Enforces consistent formatting via nixfmt-tree |
| `statix` | Lints for anti-patterns — enforces `inherit` over explicit assignment |

Pre-push hooks (block the push if the build fails):

| Platform | Command |
|---|---|
| darwin | `nix build .#darwinConfigurations.samuelwaiweng.system` |
| linux | `nix build .#nixosConfigurations.nixos.config.system.build.toplevel` |

### Manual checks

```sh
# Evaluate + type-check all outputs for the current system
nix flake check

# Dry-run build without activating (safe — nothing changes)
darwin-rebuild build --flake .#samuelwaiweng
nix build .#nixosConfigurations.nixos.config.system.build.toplevel

# Lint only
statix check .
deadnix .

# Format check only (no write)
nixfmt --check .
```

### Rollback

Every activation creates a new generation. If something breaks, roll back instantly:

```sh
# macOS
sudo darwin-rebuild switch --rollback

# NixOS (all variants)
sudo nixos-rebuild switch --rollback

# NixOS — pick a specific generation
nix-env --list-generations --profile /nix/var/nix/profiles/system
sudo nixos-rebuild switch --profile /nix/var/nix/profiles/system-<N>-link
```

---

## CI Pipeline

GitHub Actions runs a matrix across both architectures on every push and PR:

| Job | Runner | Checks |
|---|---|---|
| `check-darwin` | `macos-latest` (aarch64) | `nix flake check`, nixfmt, statix, deadnix, `darwin-rebuild build .#samuelwaiweng` |
| `check-linux` | `ubuntu-latest` (x86_64) | `nix flake check`, nixfmt, statix, deadnix, `nix build .#nixosConfigurations.nixos.config.system.build.toplevel` |

Uses `DeterminateSystems/nix-installer-action` with `determinate: false` — the Determinate installer binary, but running standard Nix (avoids FlakeHub authentication requirements).

---

## Design Principles

### Clean flake.nix
`flake.nix` only declares inputs and calls lib helpers. No inline modules, no `let primaryUser = ...` blocks.

```nix
darwinConfigurations."samuelwaiweng" = lib.mkDarwin {
  hostname = "samuelwaiweng";
  system   = "aarch64-darwin";
  user     = "KangaZero";       # logical key — resolves to OS username inside lib
};

nixosConfigurations."nixos" = lib.mkWSL {
  hostname = "nixos";
  system   = "x86_64-linux";
  user     = "KangaZero";
};
```

### User profiles
One directory per real person in `home/profiles/`. All platform-specific details (OS username, UID/GID, git identities) live in `default.nix` for that person. The lib helpers resolve the right OS username automatically.

```nix
# home/profiles/KangaZero/default.nix
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
     user     = "KangaZero";
   };

   # NixOS bare metal
   nixosConfigurations."<hostname>" = lib.mkNixOS {
     hostname = "<hostname>";
     system   = "x86_64-linux";
     user     = "KangaZero";
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
| `bash.nix`, `weston.nix` | linux | WSL config |
| `shell.nix` (catppuccin, WSL aliases) | linux | WSL config |

### packages split

Common subset extracted to `home/modules/common/packages/common.nix`:
`fzf`, `ripgrep`, `bat`, `eza`, `curl`, `jq`, `btop`, `yazi`, `fd`, `nodejs`, `pnpm`, `rustup`, `python3`, `mise`, `just`, `claude-code`, `nerd-fonts.jetbrains-mono`, `gh`

Platform-only packages stay in `home/modules/darwin/packages.nix` and `home/modules/linux/packages.nix`.

---

## Migration Steps

- [x] **Step 1** — README and repo structure plan
- [x] **Step 2** — Scaffold: full directory structure, lib helpers, CI, `.envrc`
- [x] **Step 3** — Migrate darwin: all system + home modules ported; `common/` modules written
- [x] **Step 4** — Migrate NixOS/WSL: port WSL config; verify `nix build .#nixosConfigurations.nixos.config.system.build.toplevel`
- [ ] **Step 5** — Verify both builds pass end-to-end
- [ ] **Step 6** — Archive old repos

## Verification

Run these before any significant change to confirm everything evaluates clean:

```sh
nix flake check                                                    # all outputs
darwin-rebuild build --flake .#samuelwaiweng                          # macOS dry-run
nix build .#nixosConfigurations.nixos.config.system.build.toplevel  # NixOS WSL dry-run
nix run .#kitty                                                    # kitty wrapper
statix check . && deadnix . && nixfmt --check .                   # lints
```
