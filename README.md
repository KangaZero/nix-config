# nix-config

A unified Nix flake monorepo consolidating macOS (nix-darwin) and NixOS configurations into a single, multi-platform, multi-user setup.

> **Just want the Neovim config?** → [`home/modules/common/neovim/config/`](home/modules/common/neovim/config/README.md) — standalone, no Nix required.

## Supported Platforms

| Host | OS | Architecture | Status |
|---|---|---|---|
| `KangaZero` | macOS (nix-darwin) | aarch64-darwin | Active |
| `nixos` | NixOS WSL2 | x86_64-linux | Active |
| `server` | NixOS headless | x86_64/aarch64-linux | Planned |

## Nixpkgs Source

This repo uses [`DeterminateSystems/nixpkgs-weekly`](https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1) — a mirror of `nixpkgs-unstable`, but with packages released needing to be published for at least **7-days**.

This guards against malicious packages reaching users before detection, a growing concern following supply-chain attacks on registries like npm and the AUR. See [the announcement](https://determinate.systems/posts/nixpkgs-cooldown/) for details.

To live dangerously, use raw `nixpkgs-unstable` instead, swap the input in `flake.nix`:

```nix
nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
```

---

## Defaults

| Category | Common | macOS (darwin) | NixOS WSL |
|---|---|---|---|
| **Shell** | zsh + oh-my-zsh | — | — |
| **Prompt** | oh-my-posh (TOML config in `home/modules/common/oh-my-posh.toml`) | — | — |
| **Editor** | neovim — `defaultEditor`, config HM-managed via `xdg.configFile` → `~/.config/nvim`; `vi`/`vim` aliases | — | root nvim symlinked to user config via activation script |
| **Terminal** | kitty — Tokyo Night Moon, JetBrains Mono, 85% opacity | animated pixel-art gif bg | static `moon_dark.png` bg |
| **Font** | `nerd-fonts.jetbrains-mono` | — | `fonts.fontconfig.enable = true` |
| **Multiplexer** | zellij | — | — |
| **Nav** | zoxide | — | — |
| **Browser** | Firefox Developer Edition (declarative — policies + Vimium) | — | — |
| **Desktop** | — | native macOS | niri (Wayland tiling) → weston (kiosk-shell) → WSLg; `Alt` mod; `LIBGL_ALWAYS_SOFTWARE=1` |
| **Bar / launcher / notifications** | — | — | noctalia v5 (autostarted by niri); config managed as Nix attrset in `noctalia.nix` via `programs.noctalia.settings` |
| **Clipboard** | — | — | noctalia built-in clipboard panel (`Alt+Shift+V` → `noctalia-shell ipc call clipboard toggle`) |
| **Languages** | `nodejs_26` + `pnpm`, `python3`, `rustup`, `just`, `mise` | — | + `uv` |
| **Local LLM** | — | ollama (Metal, launchd agent) — models pulled manually | ollama (`ollama-vulkan`, systemd user service) — `qwen2.5:7b` pulled manually post-activation |
| **LSP / formatters** | `lua-language-server` `bash-language-server` `pyright` `ruff` `clang-tools` `vtsls` `vscode-langservers-extracted` `biome` `tailwindcss-language-server` `nixd` `stylua` `nixfmt-rfc-style` (all in `neovim.nix` — Mason uses these from PATH, no binary downloads); `rust-analyzer` via `rustup component add rust-analyzer` | — | — |
| **CLI toolkit** | `fzf` `yazi` `eza` `bat` `btop` `ripgrep` `fd` `jq` `curl` `gh` `claude-code` `nh` | + `vim` `fastfetch` `tree` `ffmpeg-full` `imagemagick` `_7zz` `yt-dlp` `resvg` `poppler` `odysseus` | + `wget` `openssh` `tldr` `ffmpeg-full` `unzip` `uv` `azure-cli` (+ DevOps ext) |
| **Git** | LFS, `pull.rebase = true`, `autoSetupRemote = true`, identity from `userMeta` | — | — |
| **Nix daemon** | — | Determinate Systems installer (`nix.enable = false`) | NixOS-managed |
| **GC** | — | — | daily, `--delete-older-than 7d` |
| **Timezone** | — | — | Asia/Tokyo |
| **Extras** | direnv + nix-direnv, nix-search wrapper | Discord, nix-homebrew, keyboard layouts `us,jp` | xwayland, `nixRebuildStatus`/`nixRebuildKill` aliases, `uinput` (input device emulation — `hardware.uinput.enable`, auto-loaded via systemd, `uinput` group) |

---

## Setup & Usage

> **Repo location expected by shell aliases:** `~/.config/multi-nix`

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
git clone https://github.com/KangaZero/nix-config ~/.config/multi-nix
cd ~/.config/multi-nix
```

**3. First-time bootstrap** (nix-darwin not yet installed)

```sh
nix run nix-darwin/master -- switch --flake .#KangaZero
```

**4. Day-to-day rebuilds**

```sh
# Shell aliases set by this config (work from anywhere):
nix-switch   # sudo darwin-rebuild switch --flake ~/.config/multi-nix#KangaZero
nix-build    # darwin-rebuild build   --flake ~/.config/multi-nix#KangaZero
nh-switch    # nh os switch ~/.config/multi-nix#KangaZero  (prettier output + nvd diff)
nh-build     # nh os build  ~/.config/multi-nix#KangaZero

# Directly from the repo:
darwin-rebuild switch --flake .#KangaZero
nh os switch .#KangaZero
```

**5. Dry-run / build check (no activation)**

```sh
darwin-rebuild build --flake .#KangaZero
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
nix-shell -p git --run "git clone https://github.com/KangaZero/nix-config ~/.config/multi-nix"
cd ~/.config/multi-nix
```

**3. First-time activation**

```sh
sudo nixos-rebuild switch --flake .#nixos
```

Restart the instance after the first switch so shell and user settings take effect:

```powershell
wsl --terminate NixOS && wsl -d NixOS
```

**4. Day-to-day rebuilds**

```sh
sudo nixos-rebuild switch --flake ~/.config/multi-nix#nixos
# or from inside the repo:
sudo nixos-rebuild switch --flake .#nixos

# Shell aliases (work from anywhere):
nix-switch   # sudo nixos-rebuild switch --flake ~/.config/multi-nix#nixos
nh-switch    # nh os switch ~/.config/multi-nix#nixos  (prettier output + nvd diff)
nh-build     # nh os build  ~/.config/multi-nix#nixos
```

**5. Dry-run / build check (no activation)**

```sh
nixos-rebuild dry-build --flake .#nixos
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
nix-shell -p git --run "git clone https://github.com/KangaZero/nix-config /mnt/home/KangaZero/.config/multi-nix"
cp /mnt/etc/nixos/hardware-configuration.nix \
   /mnt/home/KangaZero/.config/multi-nix/hosts/<hostname>/hardware.nix
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
sudo nixos-install --flake /mnt/home/KangaZero/.config/multi-nix#<hostname> --root /mnt
reboot
```

**6. Day-to-day rebuilds**

```sh
sudo nixos-rebuild switch --flake ~/.config/multi-nix#<hostname>
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

#### No sudo access (shared host)

If you don't own the machine and can't run `nixos-rebuild`, use standalone home-manager instead — it only touches user-space (`~/.config`, `~/.local`, symlinks), no root required.

1. Uncomment the `homeConfigurations` block in `flake.nix` and set the correct system:
   ```nix
   homeConfigurations."KangaZero" = lib.mkHome {
     system = "x86_64-linux";
     user   = "KangaZero";
   };
   ```
2. Apply:
   ```sh
   nh home switch ~/.config/multi-nix#KangaZero
   # or
   home-manager switch --flake ~/.config/multi-nix#KangaZero
   ```

---

### Rebuild quick reference

| Platform | Command |
|---|---|
| macOS — switch | `darwin-rebuild switch --flake .#KangaZero` |
| macOS — alias | `nix-switch` |
| macOS — nh alias | `nh-switch` / `nh-build` |
| macOS — build only | `darwin-rebuild build --flake .#KangaZero` |
| macOS — rollback | `sudo darwin-rebuild switch --rollback` |
| NixOS WSL — switch | `sudo nixos-rebuild switch --flake .#nixos` |
| NixOS WSL — alias | `nix-switch` |
| NixOS WSL — nh alias | `nh-switch` / `nh-build` |
| NixOS WSL — build only | `nixos-rebuild dry-build --flake .#nixos` |
| NixOS WSL/bare — rollback | `sudo nixos-rebuild switch --rollback` |
| NixOS server — remote | `nixos-rebuild switch --flake .#server --target-host user@host --use-remote-sudo` |
| kitty wrapper | `nix run .#kitty` |
| nvim live config (no rebuild) | `nvim-dev` (alias for `NVIM_APPNAME=multi-nix/home/modules/common/neovim/config nvim`) |

## Repository Structure

```
multi-nix/
├── flake.nix                         # Inputs + outputs via lib helpers only
├── lib/
│   ├── default.nix                   # Re-exports all helpers
│   ├── mkDarwin.nix                  # Builds darwinSystem + home-manager
│   ├── mkNixOS.nix                   # Builds nixosSystem (bare metal / VM / server)
│   ├── mkWSL.nix                     # Thin wrapper: mkNixOS + nixos-wsl + extras
│   ├── mkHome.nix                    # Standalone home-manager config (no-sudo hosts)
│   ├── mkChecks.nix                  # Pre-commit checks per system
│   └── mkDevShell.nix                # Dev shell per system
│
├── hosts/
│   ├── KangaZero/default.nix         # macOS M4 — hostname, spotlight, shell aliases
│   ├── nixos/default.nix             # NixOS WSL2 — wsl opts, nix-ld, root nvim symlink
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
│       │   ├── oh-my-posh.nix        # Shared prompt — both darwin + linux
│       │   ├── oh-my-posh.toml       # Prompt config (dracula purple, sysinfo, git, path)
│       │   ├── neovim/
│       │   │   ├── neovim.nix        # HM module — symlinks config via xdg.configFile
│       │   │   └── config/           # Standalone nvim config (init.lua, lua/, scripts/…)
│       │   ├── zellij.nix            # zjstatus layout
│       │   ├── zoxide.nix
│       │   ├── lazygit.nix
│       │   ├── packages/
│       │   │   ├── common.nix        # Shared: fzf, ripgrep, bat, eza, jq, btop,
│       │   │   │                     #   yazi, nodejs_26, rustup, python3, mise, just,
│       │   │   │                     #   claude-code, nerd-fonts, gh
│       │   │   └── ns-script.nix     # nix-search-tv shell wrapper
│       │   └── shell/
│       │       └── zsh-core.nix      # Shared zsh: completion, autosuggestion,
│       │                             #   syntaxHighlighting, history
│       ├── darwin/                   # macOS home-manager modules
│       │   ├── packages.nix          # _7zz, imagemagick, odysseus-dev, etc.
│       │   ├── shell.nix             # brew shellenv, mac aliases
│       │   ├── discord.nix
│       │   └── ollama.nix            # ollama (Metal) — launchd agent (port 11434)
│       └── linux/                    # Linux home-manager modules
│           ├── packages.nix          # azure-cli, uv, openssh, wget, etc.
│           ├── ollama.nix            # ollama-vulkan — systemd user service (port 11434)
│           ├── bash.nix              # zsh trampoline
│           ├── shell.nix             # zsh aliases + WSL helpers (weston, kill-port, nix-gc)
│           ├── weston.nix            # Weston compositor bridge (WSL)
│           └── wayland/
│               └── niri/             # Niri KDL + noctalia v5; settings as Nix attrset in noctalia.nix
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
        ├── ci.yml                    # Matrix CI: lint + dry-build per architecture
        └── cron.yml                  # Weekly CVE report — vulnix on both arches, single commit
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
cd ~/.config/multi-nix
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
| `nvim-lua-syntax` | Parses every staged `.lua` file under `neovim/config/` via `nvim --clean`; fails on syntax errors |

Pre-push hooks (block the push if the build fails):

| Platform | Command |
|---|---|
| darwin | `nix build .#darwinConfigurations.KangaZero.system` |
| linux | `nixos-rebuild dry-build --flake .#nixos` |

### Manual checks

```sh
# Evaluate + type-check all outputs for the current system
nix flake check

# Dry-run build without activating (safe — nothing changes)
darwin-rebuild build --flake .#KangaZero
nixos-rebuild dry-build --flake .#nixos

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

### On every push / PR (`ci.yml`)

GitHub Actions runs a matrix across both architectures:

| Job | Runner | Checks |
|---|---|---|
| `check-darwin` | `macos-latest` (aarch64) | nixfmt, statix, deadnix |
| `check-linux` | `ubuntu-latest` (x86_64) | nixfmt, statix, deadnix |
| `check-nvim-config` | `ubuntu-latest` | Lua syntax (`nvim --clean`), stylua fmt check |

### Weekly CVE report (`cron.yml`)

Runs every Friday at 12pm JST (also triggerable via `workflow_dispatch`):

| Job | Runner | What it does |
|---|---|---|
| `cve-linux` | `ubuntu-latest` | Builds `nixosConfigurations.nixos`, runs vulnix, uploads `CVE_REPORT_WSL.md` as artifact |
| `cve-darwin` | `macos-latest` | Builds `darwinConfigurations.KangaZero.system`, runs vulnix, uploads `CVE_REPORT_DARWIN.md` as artifact |
| `commit` | `ubuntu-latest` | Downloads both artifacts, commits both reports in a single commit |

Uses `DeterminateSystems/nix-installer-action` with `determinate: false` — the Determinate installer binary, but running standard Nix (avoids FlakeHub authentication requirements).

---

## Design Principles

### Clean flake.nix
`flake.nix` only declares inputs and calls lib helpers. No inline modules, no `let primaryUser = ...` blocks.

```nix
darwinConfigurations."KangaZero" = lib.mkDarwin {
  hostname = "KangaZero";
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
| `neovim/neovim.nix` | Both | HM module — `xdg.configFile` symlinks `neovim/config/` to `~/.config/nvim`; originally WSL-only, now shared |
| `zellij.nix`, `zoxide.nix`, `lazygit.nix` | mac config | Moved into `common/` (zellij uses the zjstatus overlay) |

### Platform-specific modules

| Module | Platform | Source |
|---|---|---|
| `discord.nix` | darwin | mac config |
| `shell.nix` (brew shellenv) | darwin | mac config |
| `oh-my-posh.nix` + `oh-my-posh.toml` | common | moved from darwin — shared prompt |
| `wayland/niri/` | linux | WSL config |
| `bash.nix`, `weston.nix` | linux | WSL config |
| `shell.nix` (WSL aliases, helpers) | linux | WSL config — catppuccin theme dropped (oh-my-posh owns prompt) |

### packages split

Common subset extracted to `home/modules/common/packages/common.nix`:
`fzf`, `ripgrep`, `bat`, `eza`, `curl`, `jq`, `btop`, `yazi`, `fd`, `nodejs_26`, `pnpm`, `rustup`, `python3`, `mise`, `just`, `claude-code`, `nerd-fonts.jetbrains-mono`, `gh`

Platform-only packages stay in `home/modules/darwin/packages.nix` and `home/modules/linux/packages.nix`.

---

## Security

CVE scanning is done via [`vulnix`](https://github.com/nix-community/vulnix) against the built store closure. Reports are generated automatically every Friday via the `cron.yml` workflow, or run locally:

```sh
bash scripts/vulnix-flake.sh
```

Detects the current platform via `uname`, builds the matching config, and writes a report to:

| Platform | Build target | Report file |
|---|---|---|
| Linux / NixOS WSL | `.#nixosConfigurations.nixos.config.system.build.toplevel` | [`CVE_REPORT_WSL.md`](./CVE_REPORT_WSL.md) |
| macOS (darwin) | `.#darwinConfigurations.KangaZero.system` | [`CVE_REPORT_DARWIN.md`](./CVE_REPORT_DARWIN.md) |

---

## Verification

Run these before any significant change to confirm everything evaluates clean:

```sh
nix flake check                                                    # all outputs
darwin-rebuild build --flake .#KangaZero        # macOS dry-run
nixos-rebuild dry-build --flake .#nixos            # NixOS WSL dry-run
nix run .#kitty                                                    # kitty wrapper
statix check . && deadnix . && nixfmt --check .                   # lints
```
