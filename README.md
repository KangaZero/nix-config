<div align="center">

# ❄️ nix-config

**A unified Nix flake monorepo — macOS (nix-darwin) + NixOS, multi-platform, multi-user.**

[Platforms](#supported-platforms) • [Defaults](#defaults) • [Setup](#setup--usage) • [Structure](#repository-structure) • [Safety](#safety--checks) • [CI](#ci-pipeline) • [Security](#security) • [Neovim config →](home/modules/common/neovim/config/README.md)

![Nix Flakes](https://img.shields.io/badge/Nix-flakes-5277C3?style=flat-square&logo=nixos&logoColor=white)
![Platforms](https://img.shields.io/badge/platforms-aarch64--darwin%20%7C%20x86__64--linux-blueviolet?style=flat-square)
![nixpkgs](https://img.shields.io/badge/nixpkgs-unstable-008080?style=flat-square)
![Neovim](https://img.shields.io/badge/Neovim-%E2%89%A5%200.12-57A143?style=flat-square&logo=neovim&logoColor=white)
![Hosts](https://img.shields.io/badge/hosts-KangaZero%20%7C%20nixos%20%7C%20server-orange?style=flat-square)

</div>

> [!IMPORTANT]
> **This repo must live at `$HOME/.config/multi-nix` — that exact path *and* that exact directory
> name.** Several things hardcode it rather than deriving it:
> - `programs.nh.flake` / `darwinFlake` — `/home/<user>/.config/multi-nix` (`modules/nixos/nh.nix`),
>   `/Users/<user>/.config/multi-nix` (`home/modules/darwin/nh.nix`). Wrong path → `nh os switch`
>   with no argument resolves nothing.
> - The `nix-switch` / `home-switch` / `edit-nix` shell aliases
>   (`home/modules/linux/zsh-aliases.nix`, `hosts/KangaZero/default.nix`).
> - `nvim-dev` — `NVIM_APPNAME=multi-nix/home/modules/common/neovim/config`, resolved relative to
>   `$XDG_CONFIG_HOME`, so the **directory name** itself is part of the path.
>
> Cloning elsewhere still builds (`nixos-rebuild --flake /path#host` works fine), but every alias
> and the argument-free `nh` commands break. Relocating means editing those files.

> [!TIP]
> **Just want the Neovim config?** → [`home/modules/common/neovim/config/`](home/modules/common/neovim/config/README.md) — standalone, no Nix required.

## Table of Contents

- [Supported Platforms](#supported-platforms)
- [Nixpkgs Source](#nixpkgs-source)
- [Defaults](#defaults)
  - [NixOS server (bare-metal desktop)](#nixos-server-bare-metal-desktop)
- [Garbage Collection (`nh`)](#garbage-collection-nh)
- [Setup & Usage](#setup--usage)
  - [macOS — nix-darwin](#macos--nix-darwin-aarch64-darwin)
  - [NixOS WSL2](#nixos-wsl2-x86_64-linux)
  - [NixOS bare metal / VM](#nixos-bare-metal--vm-x86_64-linux-or-aarch64-linux)
  - [NixOS bare-metal desktop — `server`](#nixos-bare-metal-desktop--server-x86_64-linux)
  - [Rebuild quick reference](#rebuild-quick-reference)
- [Repository Structure](#repository-structure)
- [Safety & Checks](#safety--checks)
- [CI Pipeline](#ci-pipeline)
- [Design Principles](#design-principles)
- [Adding a New Host](#adding-a-new-host)
- [Adding a New User](#adding-a-new-user)
- [Module Migration Plan](#module-migration-plan)
- [Security](#security)
- [Verification](#verification)

## Supported Platforms

| Host | OS | Architecture | Status |
|---|---|---|---|
| `KangaZero` | macOS (nix-darwin) | aarch64-darwin | Active |
| `nixos` | NixOS WSL2 | x86_64-linux | Active |
| `server` | NixOS bare-metal (niri desktop) | x86_64-linux | Active |

## Nixpkgs Source

Currently raw **`nixpkgs-unstable`**:

```nix
nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
```

A commented-out alternative sits above it in `flake.nix`:
[`DeterminateSystems/nixpkgs-weekly`](https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1) — a
mirror of `nixpkgs-unstable` where packages must have been published for at least **7 days**. That
cooldown guards against malicious packages reaching users before detection, a growing concern after
the supply-chain attacks on registries like npm and the AUR
([announcement](https://determinate.systems/posts/nixpkgs-cooldown/)).

It is **disabled** because the FlakeHub input caused dependency-resolution failures against the other
inputs here (`home-manager`/`darwin` track `nixpkgs` via `follows`). Re-enable by swapping the two
`nixpkgs.url` lines and re-running `nix flake update` — expect to re-pin the followers if it breaks.

---

## Defaults

| Category | Common | macOS (darwin) | NixOS WSL |
|---|---|---|---|
| **Shell** | zsh + oh-my-zsh | — | — |
| **Prompt** | oh-my-posh (TOML config in `home/modules/common/oh-my-posh.toml`) | — | — |
| **Editor** | neovim — `defaultEditor`, `sideloadInitLua = true`; config HM-managed via `xdg.configFile` → `~/.config/nvim` (recursive copy); `vi`/`vim` aliases; `nvimPackLock` activation replaces `nvim-pack-lock.json` symlink with writable copy after each switch (nvim 0.12 `vim.pack` writes it at startup — read-only store symlink caused EROFS crash); treesitter folding (`foldmethod=expr`, `vim.treesitter.foldexpr()`, `foldlevel=99`) | — | root nvim symlinked to user config via activation script |
| **Terminal** | kitty — Tokyo Night Moon, JetBrains Mono, 85% opacity | animated pixel-art gif bg | static `moon_dark.png` bg |
| **Font** | `nerd-fonts.jetbrains-mono` | — | `fonts.fontconfig.enable = true` |
| **Multiplexer** | zellij | — | — |
| **Nav** | zoxide | — | — |
| **Shell history** | atuin — `programs.atuin`, zsh integration, `search_mode = "fuzzy"`, `keymap_mode = "vim-normal"`, `dialect = "uk"`, sync/update-check off (fully local). Ships a declarative theme `tokyonight-kanga` via `programs.atuin.themes` (→ `~/.config/atuin/themes/tokyonight-kanga.toml`), activated by `settings.theme.name` — Tokyo Night Moon body + Dracula purple accent, matching kitty/yazi/oh-my-posh | — | — |
| **File manager** | yazi — `programs.yazi`, Tokyo Night flavor (matches kitty), `y` shell wrapper (cd-on-quit), `show_hidden = true`, `[mgr]`/`[preview]` tuned, custom `prepend_keymap` (`gh`/`gc`/`gd` jumps, `.` toggle hidden, `!` shell) | — | — |
| **Claude Code** | **not shared — single-host, WSL only** (see note below) | commented out | `programs.claude-code` — `settings` from `slop/settings.json` → `~/.claude/settings.json` (opus model, Learning output style, vim editor, hooks, enabled LSP plugins) |
| **OpenCode** (AI coding agent) | — | `programs.opencode` (`opencode.nix`) — two local MCP servers (`shadcn` = `npx -y shadcn@latest mcp`, also serves the `@canvas-ui` registry; `playwright` = `npx -y @playwright/mcp`), `enableMcpIntegration = true`, `web.enable = false`. `extraPackages = [ nodejs pnpm typescript ]` — bundled into **opencode's own wrapper PATH** (`npx` launches the MCP servers), not the global profile, so the "no global toolchains" rule below still holds | — |
| **Browser** | Firefox Developer Edition (declarative — policies + Vimium) — darwin + `server` only; **commented out on WSL** (CLI-only host) | — | — |
| **Desktop** | — | native macOS | **CLI-only** — niri/weston/noctalia *home-manager* imports commented out in `KangaZero/linux.nix` (used as a terminal via Windows Terminal / WSLg, not a Wayland desktop). Formerly niri → weston (kiosk-shell) → WSLg; the `LIBGL_ALWAYS_SOFTWARE=1` env var is now vestigial. **Caveat:** `mkWSL` still imports the *system* module `modules/nixos/wayland/niri.nix`, so `programs.niri` + xwayland are installed (~1.1 GB closure) with no KDL config to drive them — and WSL exposes `/dev/dxg`, not `/dev/dri`, so niri cannot start there anyway |
| **Bar / launcher / notifications** | — | — | — (disabled with niri — see `server` below) |
| **Clipboard** | — | — | — (disabled with niri — see `server` below) |
| **Languages** | none in global profile — per-project `nix develop` + direnv (see note below) | — | — |
| **Local LLM** | — | ollama (Metal, launchd agent) — models pulled manually | ollama (`ollama-vulkan`, systemd user service) — `qwen2.5:7b` pulled manually post-activation |
| **Dev database** | — | — | `services.postgresql` (`postgresql_18`, in `hosts/nixos/default.nix`) — declarative `ccui` role + db (`ensureDBOwnership`), `listen_addresses = "*"` (native + Docker can connect), scram auth from localhost + Docker bridge (`172.16.0.0/12`), TCP `5432` opened. **Role password is set out-of-band** (`sudo -u postgres psql -c "ALTER ROLE ccui PASSWORD '<dev-pw>';"`) — never committed (repo is public) |
| **LSP / formatters** | `lua-language-server` `bash-language-server` `pyright` `ruff` `clang-tools` `vtsls` `typescript-go` (tsgo) `vscode-langservers-extracted` `biome` `tailwindcss-language-server` `nixd` `stylua` `nixfmt-rfc-style` (all in `neovim.nix` — self-contained nix packages, bundle their own runtime; unaffected by dropping global `nodejs`); `rust-analyzer` via `rustup component add rust-analyzer` — but `rustup` is now per-project (`neovim.nix` notes this), so add it via a project devShell first. **TS/JS: `tsgo` (typescript-go, the native TS 7 port) is the primary server, `vtsls` the fallback — only one attaches per buffer (`lsp.lua` prefers `tsgo` when it's on `PATH`), so no duplicate diagnostics** | — | — |
| **CLI toolkit** | `eza` `btop` `ripgrep` `fd` `jq` `curl` `gh` — **`fzf`** via `programs.fzf` (`fzf.nix` — defaultCommand/fileWidget/defaultOptions with tokyonight-kanga colors); **`bat`** via `programs.bat` (`bat.nix` — tokyonight-kanga tmTheme, `batdiff`/`batman`/`batgrep` via `extraPackages`); yazi via `programs.yazi`; `nh` via `programs.nh` — system-level on NixOS, home-manager on darwin, which also exports `NH_FLAKE`; claude-code is WSL-only | + `ani-cli` `vim` `fastfetch` `tree` `ffmpeg-full` `imagemagick` `_7zz` `yt-dlp` `resvg` `poppler` `odysseus` | + `wget` `openssh` `tldr` `ffmpeg-full` `unzip` `azure-cli` (+ DevOps + `containerapp` exts — `containerapp` needs `pythonRelaxDeps = ["kubernetes"]` to build) `gcc` `gnumake` (treesitter parser compilation) `wl-clipboard` (`uv` removed — now per-project, see note below) |
| **Git** | LFS, `pull.rebase = true`, `autoSetupRemote = true`, identity from `userMeta`; **delta** as pager (`programs.git.delta`) — tokyonight-kanga syntax theme, side-by-side, line numbers, hunk navigation | — | — |
| **Nix daemon** | — | Determinate Systems installer (`nix.enable = false`) | NixOS-managed |
| **GC** | `nh clean all` — see [Garbage Collection](#garbage-collection-nh) | root `launchd.daemons.nh-clean` (`modules/darwin/nh-clean.nix`) — Sundays 15:00, `--keep 3 --keep-since 7d` | `programs.nh.clean` systemd timer (`modules/nixos/nh.nix`) — weekly, `--keep 3 --keep-since 7d` |
| **Timezone** | — | — | Asia/Tokyo |
| **SSH** | — | — | `sshd` enabled, key-only auth (`PasswordAuthentication=false`, `KbdInteractiveAuthentication=false`); authorized key via `openssh.authorizedKeys.keys` |
| **Extras** | direnv + nix-direnv, nix-search wrapper, `nix-shell-init` (scaffolds a project `flake.nix` + `.envrc` — see below) | Discord, nix-homebrew, keyboard layouts `us,jp` | xwayland, `nixRebuildStatus`/`nixRebuildKill` aliases, `ff` (fastfetch with `NixOwO.png` logo via kitty-direct, zellij-aware), `uinput` (input device emulation — `hardware.uinput.enable`, auto-loaded via systemd, `uinput` group) |

> **Why language toolchains left the global profile.** `nodejs_26`, `pnpm`, `python3`,
> `rustup`, `just` (in `home/modules/common/packages/common.nix`) and `uv` (in
> `home/modules/linux/packages.nix`) are **commented out**, not deleted. They now come from
> each project's own `nix develop` shell, auto-loaded by direnv (`.envrc` → `use flake`).
> Rationale:
> - **Smaller global closure / faster rebuilds** — the user profile no longer carries
>   multiple language runtimes.
> - **No version drift** — a project pins its own toolchain in its `flake.lock`; the global
>   profile can't silently shadow it with a different version.
> - **Because `common.nix` is shared by all three hosts, this applies to macOS and `server`
>   too — not just WSL.** `uv` lived in the Linux-only list, so it drops from WSL + `server`.
>
> Trade-offs to know: these tools are only on `PATH` **inside** a project directory, so launch
> Neovim from a direnv-activated shell — otherwise a **Mason**-installed node LSP won't find
> `node`/`npm` at runtime. LSPs declared as nixpkgs packages in `neovim.nix` bundle their own
> runtime (via `wrapProgram`) and are unaffected. For Rust, `rustup component add rust-analyzer`
> now requires `rustup` from a project devShell first.
>
> **Bootstrapping a project shell:** run `nix-shell-init` in a project dir — a universal
> shell function (in `home/modules/common/shell/shell-functions.sh`, loaded on all hosts)
> that writes a starter `flake.nix` (nixpkgs-unstable + git-hooks, a personal-identity
> pre-push guard, and a `devShells.default` with suggested toolchains commented out) plus a
> `use flake` `.envrc`, stages both so the flake can see them, and runs `direnv allow`. The
> template is derived from `~/Documents/KangaFlow/flake.nix`.
>
> The same file (loaded on all hosts) also defines two more helpers:
> - **`nixpkg-review-post <pr>`** — runs `nixpkgs-review` (via `nix-shell -p nixpkgs-review`)
>   against a `NixOS/nixpkgs` PR and posts the result as a PR comment. Validates that the arg is
>   numeric and the PR exists, and reuses your `gh auth token` as `GITHUB_TOKEN` (fails fast if
>   `gh` is missing or unauthenticated). Also aliased as `nixpkg-review-post`.
> - **`cdroot`** — `cd` to the current git repo's top level (`git rev-parse --show-toplevel`).

> **Claude Code is WSL-only.** `programs.claude-code` sits in `common/`, but only
> `home/profiles/KangaZero/linux.nix` imports it — `server` (also `x86_64-linux`) does not. On
> darwin the import in `darwin.nix` **and** the `"claude-code"` entry in `lib/mkDarwin.nix`'s
> `allowUnfreePredicate` both need uncommenting; it is unfree, so the import alone fails eval.

> **The WSL host is now CLI-only.** `firefox`, `kitty`, `weston`, and the `niri`/`noctalia`
> imports are commented out in `home/profiles/KangaZero/linux.nix` purely to cut WSL build
> time — WSL is driven as a terminal (Windows Terminal / WSLg), not a Wayland desktop. This is
> **WSL-scoped**: the `server` host has its own profile and keeps the full niri + noctalia
> desktop, Firefox, and kitty. (Leftovers on WSL that are now inert: the `programs.kitty.settings`
> block, `LIBGL_ALWAYS_SOFTWARE=1`, and the `weston()` shell function in `linux/shell.nix` —
> none break evaluation, but they reference things WSL no longer installs.)

### NixOS server (bare-metal desktop)

The `server` host reuses the entire WSL home profile and shares the `KangaZero` identity
(`home/profiles/server/default.nix` re-exports `home/profiles/KangaZero/default.nix`), but is a
real Wayland desktop rather than a WSLg bridge. It is built via `lib.mkNixOS` directly (not
`mkWSL`), pulling the non-WSL subset of extra modules: `graphics`, `wayland/niri`. (`nix-ld` is no
longer listed per-host — `mkNixOS` imports it for every NixOS host.)

| Category | `server` |
|---|---|
| **Same as WSL** | zsh + oh-my-posh, neovim (incl. `nvimPackLock` activation), kitty, zellij, zoxide, firefox, git (work identity), niri KDL + **noctalia v5** config (bar/widgets/theme/idle/nightlight/session — shared base), ollama, `nh`, common + linux packages (`gcc` `gnumake` `wl-clipboard`), Asia/Tokyo, key-only sshd |
| **Desktop** | niri (Wayland tiling) launched **natively** via greetd — no weston bridge, no `LIBGL_ALWAYS_SOFTWARE`; `Alt` mod |
| **Login** | greetd + **noctalia-greeter** (`programs.noctalia-greeter`, themed session picker); input `noctalia-greeter` flake |
| **Idle / lock** | noctalia built-in Idle service — lock at 10 min, screen-off at 11 min (`programs.noctalia.settings.idle`); no swayidle |
| **Audio** | PipeWire (`alsa` + `pulse`, `rtkit`), PulseAudio disabled |
| **Graphics** | Intel — `hardware.graphics.enable` + `intel-media-driver`; `enable32Bit` from `modules/nixos/graphics.nix`, which is now a **`server`-only** extra module (WSL dropped it — `nixos-wsl` already sets `hardware.graphics.enable`, so `enable32Bit` really pulled 32-bit mesa into a CLI-only closure) |
| **Power** | `power-profiles-daemon` (noctalia-integrated — **not** TLP), `brightnessctl`; `upower.enable = true` (Battery widget) |
| **Bluetooth** | `hardware.bluetooth` (powerOnBoot) — noctalia Control Center is the UI |
| **Printing** | CUPS (`services.printing`) |
| **Secrets / polkit** | gnome-keyring (unlocked via greetd PAM), `security.polkit`, polkit-gnome user agent bound to `graphical-session.target`; GnuPG agent (`gnupg.agent`, SSH support enabled) |
| **Fonts** | `nerd-fonts.jetbrains-mono` + Noto (`noto-fonts`, `-cjk-sans`, `-cjk-serif`, `-color-emoji`), fontconfig `defaultFonts` (mono JetBrainsMono NF, CJK Noto) |
| **Portals** | `xdg-desktop-portal-gtk` + `-gnome` |
| **GC** | `programs.nh.clean`, weekly, `--keep 5 --keep-since 30d` — the only host that overrides the base retention (`programs.nh.clean.extraArgs` in `hosts/server/default.nix`; the base value is `lib.mkDefault`, so a plain assignment wins instead of erroring on a merge conflict). WSL takes the base window |
| **Dropped vs old box** | fcitx5/ja input, Steam |
| **Aliases** | `nh-switch`/`nh-build`/`nh-test`/`nh-boot`/`nh-rollback`/`nh-info` (primary) + `nix-switch`/`home-switch`/`edit-nix`/`nvim-dev` — shared with WSL via `home/modules/linux/zsh-aliases.nix`. The `nh-*` aliases take **no flake argument**: `programs.nh.flake` exports `NH_FLAKE` and nh resolves the attribute from the running hostname, so nothing host-specific is interpolated. `${hostname}` is still injected into the legacy `nix-switch` alias (WSL → `#nixos`, server → `#server`) |

Because home-manager is wired through `nixos-rebuild`, home-only tweaks can also be applied fast
without sudo/reboot via the standalone `homeConfigurations."KangaZero"` output — see
[No sudo access](#no-sudo-access-shared-host--fast-home-only-iteration).

---

## Garbage Collection (`nh`)

Store cleanup runs through **[`nh`](https://github.com/nix-community/nh)** on every host.
`nh clean all` sweeps every profile (system, home-manager, per-user) plus gcroots and then the
store in one pass, and its `--keep` is a generation *floor* on top of the `--keep-since` age
window — whichever keeps more wins, so a rollback target always survives.

| Host | Mechanism | Schedule | Retention |
|---|---|---|---|
| `nixos` (WSL) | `programs.nh.clean` → systemd `nh-clean` service + timer | weekly, `Persistent = true` | `--keep 3 --keep-since 7d` |
| `server` | same | weekly | `--keep 3 --keep-since 30d` (age window only) |
| `KangaZero` (macOS) | root `launchd.daemons.nh-clean` (hand-rolled) | Sundays 15:00 | `--keep 3 --keep-since 7d` |

Base policy is `lib.mkDefault` in **`modules/nixos/nh.nix`**, so a host overrides it with a plain
assignment (`programs.nh.clean.extraArgs` in `hosts/server/default.nix`). Without `mkDefault` the
two definitions sit at equal priority and the merge is a hard eval error, not a silent win.

> [!WARNING]
> `extraArgs` must be set explicitly. It defaults to `""`, and nh's own defaults are
> `--keep 1 --keep-since 0h` — enabling `clean` without it prunes a host to a single generation.
> Also keep `nix.gc.automatic` off: the module only *warns* on the conflict, so both timers would
> run and contend for the store lock.

### macOS

nix-darwin ships no `programs.nh`, and `nix.enable = false` here (Determinate installer owns the
daemon) leaves no `nix.gc` either, so it takes two pieces:

- **`modules/darwin/nh-clean.nix`** — root `launchd.daemons.nh-clean` running `nh clean all`. Root
  is required for `/nix/var/nix/profiles/system`, where `darwin-rebuild` generations live.
  `environment.PATH` is explicit because a launchd daemon starts with a near-empty environment and
  nh shells out to the Determinate `nix` in `/nix/var/nix/profiles/default/bin`. `RunAtLoad` is off
  so a GC can't race an activation for the store lock. Logs to `/var/log/nh-clean.log`.
- **`home/modules/darwin/nh.nix`** — home-manager `programs.nh`, for `NH_DARWIN_FLAKE` only.
  `clean.enable = false`: it could schedule only `nh clean user` (unprivileged agent), which the
  root sweep already covers — both would mean two GCs on one store lock.

### Manual sweep

`nix-gc` is a shell function in `home/modules/common/shell/shell-functions.sh`, loaded on **all**
hosts (it was previously Linux-only):

```sh
nix-gc          # nh clean all --keep 3 --keep-since 7d   (default window)
nix-gc 30d      # nh clean all --keep 3 --keep-since 30d
nh clean all -n # dry run — print what would be removed, remove nothing
nh clean all -a # ask for confirmation per profile
```

> [!NOTE]
> `nh` comes from `programs.nh` — the **system** config on NixOS, the **darwin** home profile on
> macOS. The standalone `homeConfigurations."KangaZero"` output does not include it, so `nix-gc`
> there fails with a hint pointing at `nix run nixpkgs#nh -- clean all ...`.

---

## Setup & Usage

> [!NOTE]
> Every command below assumes the repo is at `~/.config/multi-nix` — see the note at the top.

---

### macOS — nix-darwin (aarch64-darwin)

**Prerequisites:** Apple Silicon Mac.

**1. Install Nix (Determinate Systems — recommended)**

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

> [!IMPORTANT]
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

**4. Day-to-day rebuilds — `nh` is the primary path**

```sh
# nh aliases (work from anywhere; no flake argument — programs.nh.darwinFlake
# exports NH_DARWIN_FLAKE):
nh-switch    # nh darwin switch   (prettier output + nvd closure diff)
nh-build     # nh darwin build
nh-repl      # nh darwin repl

# Native fallback, kept for the subcommands nh's darwin driver lacks:
nix-switch   # sudo darwin-rebuild switch --flake ~/.config/multi-nix#KangaZero
nix-build    # darwin-rebuild build   --flake ~/.config/multi-nix#KangaZero
```

> [!NOTE]
> macOS uses `nh darwin`, not `nh os` — in nh 4.x `os` is NixOS-only.

**5. Dry-run / build check (no activation)**

```sh
nh-build                                  # nh darwin build
darwin-rebuild build --flake .#KangaZero  # equivalent, native
```

**6. Roll back** the last activation if something breaks

```sh
nix-rollback   # sudo darwin-rebuild switch --rollback
```

> [!NOTE]
> Rollback stays on `darwin-rebuild`. nh 4.4.2's `darwin` subcommand implements only
> `switch` / `build` / `repl` — there is no `nh darwin rollback` or `nh darwin info`
> (the NixOS driver has both). Verify with `nh darwin --help` before assuming parity.

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

**4. Day-to-day rebuilds — `nh` is the primary path**

```sh
# nh aliases (work from anywhere; no flake argument — programs.nh.flake exports
# NH_FLAKE, and nh resolves the attribute from the running hostname):
nh-switch    # nh os switch   (prettier output + nvd closure diff)
nh-build     # nh os build
nh-test      # nh os test     — activate without touching the boot default
nh-boot      # nh os boot     — stage for next boot, don't activate now
nh-info      # nh os info     — list generations

# Native fallback:
nix-switch   # sudo nixos-rebuild switch --flake ~/.config/multi-nix#nixos
```

**5. Dry-run / build check (no activation)**

```sh
nh-build                              # nh os build
nixos-rebuild dry-build --flake .#nixos
```

**6. Roll back** if something breaks

```sh
nh-rollback   # nh os rollback
nh-info       # nh os info — inspect generations first

# Native equivalents / pick a specific generation:
sudo nixos-rebuild switch --rollback
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
nh os switch                 # NH_FLAKE + hostname are already set by programs.nh
# native fallback:
sudo nixos-rebuild switch --flake ~/.config/multi-nix#<hostname>
```

**7. Roll back**

```sh
nh os rollback
# native fallback:
sudo nixos-rebuild switch --rollback
```

---

### NixOS bare-metal desktop — `server` (x86_64-linux)

The `server` host is a full niri + noctalia Wayland desktop (greetd login, PipeWire, CUPS,
Bluetooth, Intel graphics). It is already registered in `flake.nix` via `lib.mkNixOS` with the
non-WSL extra modules:

```nix
nixosConfigurations."server" = lib.mkNixOS {
  hostname     = "server";
  system       = "x86_64-linux";
  user         = "server";                       # profile dir; username resolves to "KangaZero"
  extraModules = [                               # nix-ld comes from mkNixOS itself
    ./modules/nixos/graphics.nix
    ./modules/nixos/wayland/niri.nix
  ];
};
```

**1. Install** (from the NixOS installer — follow the *bare metal* partition/mount steps above,
then generate hardware config into `hosts/server/hardware.nix`):

```sh
sudo nixos-install --flake /mnt/home/KangaZero/.config/multi-nix#server --root /mnt
reboot
```

> Before the first switch: paste your real SSH pubkey into `hosts/server/default.nix`
> (`openssh.authorizedKeys.keys`) and confirm the `hosts/server/hardware.nix` UUIDs match the
> target disk (`lsblk -f`).

**2. Day-to-day system rebuilds** (bootloader/greetd/daemons):

```sh
# server-local aliases (after first switch) — nh first:
nh-switch    # nh os switch
nh-build     # nh os build
nh-rollback  # nh os rollback
nh-info      # nh os info

# native fallback:
nix-switch   # sudo nixos-rebuild switch --flake ~/.config/multi-nix#server
sudo nixos-rebuild switch --flake ~/.config/multi-nix#server
```

Reboot once after the first switch (bootloader + greetd), then pick the **niri** session in
noctalia-greeter. Subsequent tweaks apply live — no more reboots.

<a id="no-sudo-access-shared-host--fast-home-only-iteration"></a>
#### No sudo access (shared host) / fast home-only iteration

Home-manager is wired through `nixos-rebuild`, but the standalone
`homeConfigurations."${serverHomeManagerUser}"` output (`serverHomeManagerUser = "KangaZero"`) lets
you apply **home-only** changes (niri/noctalia/kitty/zsh/nvim/packages) without sudo or a reboot —
useful both on a machine you don't own and for fast local iteration. It only touches user-space
(`~/.config`, `~/.local`, symlinks).

The block is already active in `flake.nix`:

```nix
serverHomeManagerUser = "KangaZero";              # output key / activation target
# ...
homeConfigurations."${serverHomeManagerUser}" = lib.mkHome {
  system   = serverSystem;                        # "x86_64-linux"
  user     = serverUser;                          # "server" (loads home/profiles/server/linux.nix)
  hostname = serverHostname;                      # "server" — used by zsh-aliases.nix for nh/nix-switch targets
};
```

Apply:

```sh
home-switch   # home-manager switch --flake ~/.config/multi-nix#KangaZero  (server-local alias)
# or, via nh (NH_FLAKE is already exported, so the path is optional):
nh home switch -c KangaZero
# native:
home-manager switch --flake ~/.config/multi-nix#KangaZero
```

> `nh home` needs `-c/--configuration` here: the home output is keyed `KangaZero` (the Linux
> username), which does not match the `server` hostname nh would otherwise guess.

> System-level pieces (greetd, PipeWire, CUPS, fonts, kernel) still require `nixos-rebuild switch`.
> Both paths read the same `home/profiles/server/linux.nix`, so they don't fight — but don't hand-
> edit noctalia via its UI expecting it to persist; the declared `noctalia.nix` settings win on the
> next switch.

---

### Rebuild quick reference

`nh` is the primary driver on every host. None of the `nh-*` aliases take a flake argument —
`programs.nh` exports `NH_FLAKE` (NixOS) / `NH_DARWIN_FLAKE` (darwin), and nh resolves the
attribute from the hostname.

| Task | nh (primary) | Native fallback |
|---|---|---|
| macOS — switch | `nh-switch` → `nh darwin switch` | `sudo darwin-rebuild switch --flake .#KangaZero` (alias `nix-switch`) |
| macOS — build only | `nh-build` → `nh darwin build` | `darwin-rebuild build --flake .#KangaZero` |
| macOS — repl | `nh-repl` → `nh darwin repl` | — |
| macOS — rollback | **n/a** — no `nh darwin rollback` in nh 4.4.2 | `nix-rollback` → `sudo darwin-rebuild switch --rollback` |
| macOS — list generations | **n/a** — no `nh darwin info` | `nix-env --list-generations --profile /nix/var/nix/profiles/system` |
| NixOS WSL/server — switch | `nh-switch` → `nh os switch` | `sudo nixos-rebuild switch --flake .#<host>` (alias `nix-switch`) |
| NixOS WSL/server — build only | `nh-build` → `nh os build` | `nixos-rebuild dry-build --flake .#<host>` |
| NixOS WSL/server — activate, keep boot default | `nh-test` → `nh os test` | `sudo nixos-rebuild test` |
| NixOS WSL/server — stage for next boot | `nh-boot` → `nh os boot` | `sudo nixos-rebuild boot` |
| NixOS WSL/server — rollback | `nh-rollback` → `nh os rollback` | `sudo nixos-rebuild switch --rollback` |
| NixOS WSL/server — list generations | `nh-info` → `nh os info` | `nix-env --list-generations --profile /nix/var/nix/profiles/system` |
| Any host — garbage collect now | `nix-gc [age]` → `nh clean all --keep 3 --keep-since <age>` | — |
| NixOS server — home-only (no sudo) | `nh home switch -c KangaZero` | `home-manager switch --flake .#KangaZero` (alias `home-switch`) |
| NixOS server — remote | — | `nixos-rebuild switch --flake .#server --target-host user@host --use-remote-sudo` |
| kitty wrapper | — | `nix run .#kitty` |
| nvim live config (no rebuild) | — | `nvim-dev` (alias for `NVIM_APPNAME=multi-nix/home/modules/common/neovim/config nvim`) |

## Repository Structure

```
multi-nix/
├── flake.nix                         # Inputs + outputs via lib helpers only
├── lib/
│   ├── default.nix                   # Re-exports all helpers
│   ├── mkDarwin.nix                  # Builds darwinSystem + home-manager
│   ├── mkNixOS.nix                   # Builds nixosSystem (bare metal / VM / server) + nix-ld
│   ├── mkWSL.nix                     # Thin wrapper: mkNixOS + nixos-wsl + niri + passwordless sudo
│   ├── mkHome.nix                    # Standalone home-manager config (no-sudo hosts)
│   ├── mkChecks.nix                  # Pre-commit checks per system
│   └── mkDevShell.nix                # Dev shell per system
│
├── hosts/
│   ├── KangaZero/default.nix         # macOS M4 — hostname, spotlight, shell aliases
│   ├── nixos/                        # NixOS WSL2 — wsl opts, sshd, linger, uinput (GC via modules/nixos/nh.nix)
│   │   ├── default.nix
│   │   └── hardware.nix              # WSL: uinput module load
│   └── server/                       # NixOS bare-metal desktop
│       ├── default.nix               # greetd+noctalia-greeter, pipewire, cups, bluetooth, PPD, intel gfx, fonts
│       └── hardware.nix              # from nixos-generate-config (real UUIDs, kvm-intel)
│
├── modules/
│   ├── darwin/                       # nix-darwin system modules
│   │   ├── homebrew.nix              # nix-homebrew + taps + trust
│   │   ├── settings.nix              # macOS system defaults
│   │   ├── applications.nix          # Spotlight alias activation script
│   │   └── nh-clean.nix              # root launchd daemon: `nh clean all` weekly (no programs.nh on darwin)
│   ├── nixos/                        # NixOS system modules
│   │   ├── nix-ld.nix                # programs.nix-ld — imported by mkNixOS (all NixOS hosts)
│   │   ├── nh.nix                    # programs.nh + clean timer — imported by mkNixOS; base retention (mkDefault)
│   │   ├── graphics.nix              # hardware.graphics.enable32Bit — `server` only
│   │   └── wayland/
│   │       └── niri.nix              # programs.niri + xwayland (system level)
│   └── shared/
│       └── nix-settings.nix          # experimental-features, registry, nixPath — both platforms
│
├── home/
│   ├── profiles/
│   │   ├── KangaZero/
│   │   │   ├── default.nix           # User metadata: usernames, git identities, stateVersion
│   │   │   ├── darwin.nix            # Darwin home-manager entry point
│   │   │   └── linux.nix             # Linux (WSL) home-manager entry point — imports weston, LIBGL sw
│   │   └── server/
│   │       ├── default.nix           # Re-exports KangaZero/default.nix (shared identity)
│   │       └── linux.nix             # Bare-metal profile — KangaZero minus weston/LIBGL, + noctalia idle + polkit agent
│   └── modules/
│       ├── common/                   # Platform-agnostic (compiles on darwin + linux)
│       │   ├── git.nix               # Reads identities from userMeta
│       │   ├── direnv.nix
│       │   ├── firefox.nix           # Firefox Dev Edition + policies
│       │   ├── kitty.nix             # Tokyo Night Moon — bg image from assetsDir
│       │   ├── yazi.nix              # File manager — Tokyo Night flavor, keymap, settings
│       │   ├── oh-my-posh.nix        # Shared prompt — both darwin + linux
│       │   ├── oh-my-posh.toml       # Prompt config (dracula purple, sysinfo, git, path)
│       │   ├── neovim/
│       │   │   ├── neovim.nix        # HM module — symlinks config via xdg.configFile
│       │   │   └── config/           # Standalone nvim config (init.lua, lua/, scripts/…)
│       │   ├── zellij.nix            # zjstatus layout
│       │   ├── zoxide.nix
│       │   ├── atuin.nix             # Shell history — local-only, vim-normal keymap,
│       │   │                         #   declarative `tokyonight-kanga` theme; palette from theme.nix
│       │   ├── bat.nix               # programs.bat — tokyonight-kanga tmTheme (inline),
│       │   │                         #   batdiff / batman / batgrep via extraPackages
│       │   ├── fzf.nix               # programs.fzf — defaultCommand (fd), fileWidget,
│       │   │                         #   defaultOptions (tokyonight-kanga --color flags)
│       │   ├── theme.nix             # tokyonight-kanga palette — bare attrset, no module args;
│       │   │                         #   import ./theme.nix in any let block (atuin/bat/fzf)
│       │   ├── lazygit.nix           # tokyonight-kanga theme (hex colors from theme.nix), lightTheme off
│       │   ├── packages/
│       │   │   ├── common.nix        # Shared: eza, btop, ripgrep, fd, jq, curl, gh,
│       │   │   │                     #   nerd-fonts (fzf → fzf.nix; bat → bat.nix)
│       │   │   └── ns-script.nix     # nix-search-tv shell wrapper
│       │   ├── slop/
│       │   │   ├── claude-code.nix    # programs.claude-code — settings → ~/.claude/settings.json
│       │   │   └── settings.json      # Claude Code settings (model, hooks, plugins, output style)
│       │   └── shell/
│       │       ├── zsh-core.nix      # Shared zsh: completion, autosuggestion,
│       │       │                     #   syntaxHighlighting, history
│       │       └── shell-functions.sh # All-host helpers: cdroot, nix-shell-init,
│       │                             #   nixpkg-review-post, nix-gc (nh clean all)
│       ├── darwin/                   # macOS home-manager modules
│       │   ├── packages.nix          # ani-cli, _7zz, imagemagick, odysseus-dev, etc.
│       │   ├── shell.nix             # brew shellenv, mac aliases
│       │   ├── discord.nix           # programs.discord (devtools flag, skip host update)
│       │   ├── man.nix               # programs.man
│       │   ├── nh.nix                # programs.nh (HM) — NH_DARWIN_FLAKE only; clean off (root daemon owns it)
│       │   ├── opencode.nix          # programs.opencode — shadcn + playwright MCP, nodejs/pnpm/typescript toolchain
│       │   └── ollama.nix            # ollama (Metal) — launchd agent (port 11434)
│       └── linux/                    # Linux home-manager modules
│           ├── packages.nix          # azure-cli (+ devops + containerapp exts), openssh, wget, tldr, gcc, gnumake, wl-clipboard (uv removed — now per-project)
│           ├── ollama.nix            # ollama-vulkan — systemd user service (port 11434)
│           ├── bash.nix              # zsh trampoline
│           ├── shell.nix             # linux-specific aliases (ez, nixRebuildStatus/Kill, cheatsheet-az) + shell helpers (weston fn, kill-port, ff)
│           ├── zsh-aliases.nix       # rebuild aliases — nh-switch/build/test/boot/rollback/info (no flake arg) + nix-switch, home-switch, edit-nix, nvim-dev
│           ├── weston.nix            # Weston compositor bridge (WSL only — not imported by server)
│           └── wayland/
│               └── niri/             # Niri KDL + noctalia v5 (shared by WSL + server); settings as Nix attrset in noctalia.nix
│
├── overlays/
│   └── zjstatus/                     # zellij status-bar overlay — applied in mkNixOS + mkHome (and mkDarwin)
├── packages/
│   └── kitty.nix                     # nix-wrapper-modules standalone kitty
├── assets/
│   ├── mac/                          # macOS assets (background gif, etc.)
│   └── linux/                        # Linux assets (NixOwO.png fastfetch logo, wallpapers)
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
| On every commit | `deadnix`, `nixfmt`, `statix`, `betterleaks`, `nvim-lua-syntax` | Dead code, formatting drift, anti-patterns, committed secrets, broken Lua |
| On every push | `nix build` for the current platform (`.#nixos` / darwin) + git-author guard | Broken builds, and commits authored/committed under the wrong identity |
| On every PR / push to remote | CI matrix — **lint only** (`nixfmt`/`statix`/`deadnix` + nvim); config-build steps are commented out in `ci.yml` | Formatting drift, anti-patterns, dead code |
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
| `check-leaks` | `betterleaks git --staged` — blocks committed secrets/credentials (`always_run`) |

Pre-push hooks (block the push if they fail):

| Hook | What it does |
|---|---|
| `home-build` (darwin) | `nix build --no-link .#darwinConfigurations.KangaZero.system` |
| `home-build` (linux) | `nix build --no-link .#nixosConfigurations.nixos.config.system.build.toplevel` |
| `check-author` | Rejects the push unless **every** incoming commit is authored *and* committed by `KangaZero <samuelyongw@gmail.com>` — keeps the work identity out of this public repo |

> [!WARNING]
> The pre-push build covers only `.#nixos` (WSL) and darwin. A
> `checks.x86_64-linux.server-pre-commit-check` output **does** exist (added because `server` shares
> `x86_64-linux` with WSL and one system key can hold only one `pre-commit-check`), but nothing
> activates it: `mkDevShell` installs the hooks of `pre-commit-check` only, the `home-build` hook is
> `stages = [ "pre-push" ]` so `nix flake check` skips it, and `ci.yml`'s build steps are commented
> out. Net effect: the bare-metal **`server`** config is still never built automatically — verify it
> by hand: `nixos-rebuild build --flake .#server`.

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
# NixOS (all variants) — nh
nh os info        # list generations (alias nh-info)
nh os rollback    # step back one generation (alias nh-rollback)

# macOS — nh 4.4.2 has no `nh darwin rollback`; use darwin-rebuild
sudo darwin-rebuild switch --rollback     # alias nix-rollback

# NixOS — native / pick a specific generation
sudo nixos-rebuild switch --rollback
nix-env --list-generations --profile /nix/var/nix/profiles/system
sudo nixos-rebuild switch --profile /nix/var/nix/profiles/system-<N>-link
```

> The `nh clean` timers keep at least 3 generations on every host regardless of the age cutoff, so
> a rollback target always survives GC — see [Garbage Collection](#garbage-collection-nh).

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
| `hostname` | NixOS hostname (e.g. `"nixos"`, `"server"`) — used by `zsh-aliases.nix` to target the correct flake output |
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
| `fzf.nix` | common | `programs.fzf` — `defaultCommand`/`fileWidgetCommand` (fd), `defaultOptions` (tokyonight-kanga `--color` flags) |
| `bat.nix` | common | `programs.bat` — inline `tokyonight-kanga` tmTheme, `batdiff`/`batman`/`batgrep` via `extraPackages` |
| `theme.nix` | common | Shared tokyonight-kanga palette — bare attrset, imported by `atuin.nix`, `bat.nix`, `fzf.nix` |

### Platform-specific modules

| Module | Platform | Source |
|---|---|---|
| `discord.nix` | darwin | mac config |
| `shell.nix` (brew shellenv) | darwin | mac config |
| `opencode.nix` | darwin | new — `programs.opencode` (shadcn + playwright MCP, frontend toolchain) |
| `man.nix` | darwin | new — `programs.man` |
| `oh-my-posh.nix` + `oh-my-posh.toml` | common | moved from darwin — shared prompt |
| `wayland/niri/` | linux | WSL config |
| `bash.nix`, `weston.nix` | linux | WSL config |
| `shell.nix` (WSL aliases, helpers) | linux | WSL config — catppuccin theme dropped (oh-my-posh owns prompt) |

### packages split

`home/modules/common/packages/common.nix` holds the shared package list:
`eza`, `ripgrep`, `fd`, `jq`, `curl`, `btop`, `nerd-fonts.jetbrains-mono`, `gh`.
`nh` lives in `programs.nh` (`modules/nixos/nh.nix` on NixOS, `home/modules/darwin/nh.nix` on
darwin), which also exports `NH_FLAKE`/`NH_DARWIN_FLAKE` and owns the GC timer.
The language toolchains (`nodejs_26`, `pnpm`, `rustup`, `python3`, `just`) are **commented out** —
sourced from per-project `nix develop` shells (see the note under [Defaults](#defaults)).

`yazi`, `claude-code`, `fzf`, and `bat` are installed + configured declaratively via their own modules rather than the package list:
- `programs.yazi` — `yazi.nix`
- `programs.claude-code` — `slop/claude-code.nix`
- `programs.fzf` — `fzf.nix`: `defaultCommand`/`fileWidgetCommand` (fd), `defaultOptions` (tokyonight-kanga `--color` flags)
- `programs.bat` — `bat.nix`: inline `tokyonight-kanga` tmTheme, `batdiff`/`batman`/`batgrep` via `extraPackages` (batgrep wraps ripgrep, no extra dep)
- `theme.nix` — bare attrset (no module args) with the shared tokyonight-kanga palette; imported by `atuin.nix`, `bat.nix`, and `fzf.nix`

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
nh darwin build                                                    # macOS dry-run (or darwin-rebuild build --flake .#KangaZero)
nh os build                                                        # NixOS dry-run  (or nixos-rebuild dry-build --flake .#nixos)
nix-gc                                                             # nh clean all --keep 3 --keep-since 7d
nix run .#kitty                                                    # kitty wrapper
statix check . && deadnix . && nixfmt --check .                   # lints
```
