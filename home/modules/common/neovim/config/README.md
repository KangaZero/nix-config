# nvim-min

A minimal-ish, fast Neovim configuration built on **Neovim's native tooling** — the
built-in `vim.pack` plugin manager, the native `vim.lsp` config API, and the new
experimental message UI (`vim._core.ui2`). No `lazy.nvim`, no `packer`, no bootstrap
shim. Requires **Neovim ≥ 0.12** (stable as of 0.12.2).

> Heads up: this config uses APIs introduced in 0.12 (`vim.pack`,
> `vim.lsp.config`/`vim.lsp.enable`, `vim.diagnostic.jump`, `vim._core.ui2`).
> On 0.11 or older it will throw on startup.

---

## Requirements

| Tool | Why |
| --- | --- |
| **Neovim ≥ 0.12** | `vim.pack`, native LSP config, `vim._core.ui2` |
| **git** | `vim.pack` clones plugins over HTTPS |
| **A Nerd Font** | statusline / dashboard / completion icons |
| **ripgrep** (`rg`) | Telescope live grep, grug-far |
| **fzf** | Telescope find files |
| **yazi** | file manager integration (`<leader><leader>`, `<leader>E`) |
| **lazygit** | floating git UI (`<leader>gg`) |
| **node / cargo / etc.** | runtimes for the LSP servers you enable |

All optional external tools are guarded with `vim.fn.executable(...)`, so missing
binaries just disable their keymaps rather than erroring.

---

## Package management

This config uses Neovim's **built-in `vim.pack`** manager — no third-party plugin
manager.

- Plugins are declared inline with `vim.pack.add({ ... })`, spread across the files
  that actually use them (e.g. `lua/plugins/flash.lua` adds and configures Flash in
  the same place).
- **`nvim-pack-lock.json`** is the lockfile: it pins every plugin to a `rev` (commit)
  and `src` (repo URL). Commit this file to get reproducible plugin versions across
  machines.
- Update plugins with `<leader>p` (calls `vim.pack.update()`).
- A few built-in optional packages are loaded via `packadd`: `cfilter`,
  `nvim.undotree`, `nvim.difftool`.

LSP servers are installed/managed by **mason** + **mason-lspconfig** (see
`ensure_installed` in `lua/lsp.lua`), with server settings applied through the native
`vim.lsp.config(...)` API.

---

## Layout

```
./                            # home/modules/common/neovim/config/ in the flake
├── init.lua                  # entry point: sets leader, message UI, requires modules in order
├── nvim-pack-lock.json       # vim.pack lockfile (pinned plugin commits)
├── justfile                  # task runner: syntax / fmt / load checks (see Testing & CI)
├── scripts/                  # check-syntax.lua, load-test.sh, install-hooks.sh, hooks/pre-commit
│
├── lua/
│   ├── core.lua              # vim.pack.add for core plugins + treesitter/highlight-colors setup
│   ├── options.lua           # vim.o / vim.opt settings, diagnostic signs
│   ├── keymaps.lua           # all keymaps (windows, LSP, flash, treesitter textobjects, …)
│   ├── autocmds.lua          # yank highlight, format-on-save, autosave, close-with-q, …
│   ├── usercmds.lua          # :GitBlameLine — git blame for current line
│   ├── colorscheme.lua       # nekonight theme + custom highlight overrides
│   ├── lsp.lua               # mason + native vim.lsp.config per-server setup
│   │
│   ├── custom/
│   │   ├── safemode.lua      # read-only "SAFE" mode toggle (<leader>ts)
│   │   ├── terminal.lua      # toggleable bottom terminal split (<C-/>)
│   │   ├── zen.lua           # distraction-free centered window toggle (<leader>zz)
│   │   └── customlogo.py     # dashboard ASCII-art helper (script)
│   │
│   ├── ui/
│   │   └── statusline.lua    # hand-rolled statusline (mode, git, diagnostics, clock)
│   │
│   ├── plugins/
│   │   ├── init.lua          # requires every plugin module below
│   │   ├── ai.lua            # copilot.lua (the only AI plugin — easy to disable)
│   │   ├── completion.lua    # blink.cmp (lazy-loaded on InsertEnter)
│   │   ├── conform.lua       # conform.nvim formatters by filetype
│   │   ├── dashboard.lua     # dashboard-nvim + milli.nvim splash ("purgatory" theme)
│   │   ├── flash.lua         # flash.nvim motions / treesitter jumps
│   │   ├── grug-far.lua      # project-wide search & replace
│   │   ├── snacks.lua        # folke/snacks.nvim (picker, indent, scroll, notifier, …)
│   │   ├── telescope.lua     # telescope.nvim
│   │   ├── which-key.lua     # which-key.nvim
│   │   └── yazi.lua          # yazi.nvim file manager
│   │
│   └── util.lua              # 🚧 WIP — see below
│
└── after/                    # 🚧 WIP — see below
    └── queries/
        ├── lua/highlights.scm
        └── typescript/highlights.scm
```

### Load order (`init.lua`)

`core → custom/safemode → custom/terminal → lsp → plugins → options → colorscheme
→ ui/statusline → autocmds → keymaps → usercmds`

---

## 🚧 Work in progress (not load-bearing)

These are scaffolding / experiments and **should be treated as WIP**. Do not rely on
them; they are intended to play **no role** in the active config right now:

- **`lua/util.lua`** — helper library (contrast-ratio math, popup terminal builder,
  LSP symbol resolver). Some functions are referenced from elsewhere, but treat the
  module as unstable/experimental and subject to change.
- **`after/`** — currently just custom Treesitter `highlights.scm` queries that
  extend comment highlighting for `TODO|FIXME|HACK|NOTE|BUG|PERF`. Experimental; not
  required for the config to function.

---

## Plugins

| Plugin | Purpose |
| --- | --- |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | syntax / parsing |
| [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | function/class/param textobjects + motions |
| [nvim-highlight-colors](https://github.com/brenoprata10/nvim-highlight-colors) | inline color swatches (incl. tailwind) |
| [mason.nvim](https://github.com/mason-org/mason.nvim) + [mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) | install/manage LSP servers & tools |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP server definitions |
| [blink.cmp](https://github.com/saghen/blink.cmp) | completion engine (lazy on `InsertEnter`) |
| [copilot.lua](https://github.com/zbirenbaum/copilot.lua) | AI suggestions (only AI plugin) |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | format-on-save by filetype |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | fuzzy finder |
| [snacks.nvim](https://github.com/folke/snacks.nvim) | picker, indent guides, scroll, notifier, dashboard, … |
| [flash.nvim](https://github.com/folke/flash.nvim) | jump motions / treesitter selection |
| [grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim) | search & replace across project |
| [yazi.nvim](https://github.com/mikavilpas/yazi.nvim) | yazi file-manager integration |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | keymap hints |
| [dashboard-nvim](https://github.com/nvimdev/dashboard-nvim) + [milli.nvim](https://github.com/amansingh-afk/milli.nvim) | start screen + animated splash |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | lua utility dep (yazi) |

Exact pinned commits live in `nvim-pack-lock.json`.

---

## Languages / LSP

Servers in `ensure_installed` (`lua/lsp.lua`), so the config is aimed at:

- **Lua** — `lua_ls` (+ `stylua` fmt)
- **TypeScript / JavaScript** — `vtsls`, `eslint`, `biome`
- **Web** — `html`, `cssls`, `tailwindcss`, `jsonls`
- **Python** — `pyright` (+ `ruff` lint/fmt)
- **Rust** — `rust_analyzer` (+ `rustfmt`)
- **C / C++** — `clangd`
- **Bash / shell** — `bashls` (`sh`, `bash`, `zsh`)
- **Nix** — `nixd` (flake-aware: resolves host + user at runtime against `/etc/nixos`)
- **Swift** — `sourcekit` (enabled, expects a system install)

Formatters (`conform.nvim`): `stylua` (lua), `ruff` (python), `rustfmt` (rust),
`biome`/`prettier` (js/ts/json). Formatting runs on `BufWritePre`.

---

## Notable features & keymaps

Leader is **`<Space>`**.

**Navigation**
- `<C-h/j/k/l>` — move between windows (works from insert/terminal too)
- `<C-d>/<C-u>/<C-f>/<C-b>` — scroll and recenter (`zz`)
- `s` / `S` — Flash jump / Flash treesitter
- `<leader>ww/wd/wx/wv` — window next / close / swap / vsplit

**Find / search**
- `<leader><leader>` — smart picker (snacks)
- `<leader>ff` — find files · `<leader>sg`/`<leader>fg` — live grep · `<leader>fm` — search `:messages`
- `<leader>fb` — buffers · `<leader>fG` — git status
- `<leader>sr` — grug-far search & replace
- `<leader>E` — yazi at cwd · `<leader>e` — yazi at current buffer · `<leader>fc` — open Neovim config in yazi
- `<C-Up>` — resume / toggle the last yazi session

**LSP / diagnostics**
- `<leader>gd/gr/gI` — definitions / references / implementations (telescope)
- `<leader>xx` — diagnostics list (telescope) · `<leader>td` — toggle inline (virtual_lines) diagnostics
- `]e/[e`, `]w/[w` — next/prev error / warning
- `<leader>fF` — LSP format (nvim-0.12)

**Treesitter textobjects** — `af/if`, `ac/ic`, `aa/ia`, `al/il`, `ao/io`, plus
`]f/[f`, `]c/[c` motions and `<leader>as/aS` to swap parameters.

**Tools**
- `<C-/>` — toggle bottom terminal split (`custom/terminal.lua`)
- `<leader>gg` — floating lazygit
- `<leader>uu` — undotree
- `<leader>zz` — toggle **Zen mode** (distraction-free centered window; `custom/zen.lua`)
- `<leader>ts` — toggle **SAFE mode** (read-only: blocks edits/macros/paste; `<Esc>` exits)
- `<leader>p` — update plugins (`vim.pack.update()`)
- `<leader>aa` — execute current line / selection as Lua

### Custom UI
- **Statusline** (`ui/statusline.lua`) is hand-written — mode, file, git branch,
  diagnostic counts, pending keys, clock, and position. No statusline plugin.
- **Colorscheme** is `nekonight-deep-ocean` (transparent) with custom highlight
  overrides in `colorscheme.lua`. Upstream `neko-night/nvim` was removed from GitHub,
  so `colorscheme.lua` now pulls a snapshot mirror at
  [`KangaZero/nekonight.nvim`](https://github.com/KangaZero/nekonight.nvim)
  (nekonight by BrunoCiccarino, MIT, pinned at upstream commit `df1c6af`).
- **Message UI** uses the experimental `vim._core.ui2` to route messages between the
  cmdline, a message window, and a pager (configured in `init.lua`).

### Autocmds worth knowing
- **Format on save** via conform (`BufWritePre`).
- **Autosave + auto-reload**: on `BufLeave`, modified normal buffers are written; any
  saved file under the config dir is re-`source`d (live config reload).
- Yank highlight, `help` opens as a right vsplit, `q` closes utility filetypes.

---

## Install

This config is managed by **Home Manager** inside the `multi-nix` flake. There is no
manual clone step — HM symlinks `home/modules/common/neovim/config/` to
`~/.config/nvim` via `xdg.configFile."nvim".source` in `neovim.nix`.

Home Manager is integrated into the system configuration (not standalone), so it is
applied as part of the normal system rebuild — there is no separate
`home-manager switch`:

```sh
# macOS — Home Manager runs as part of the darwin system
sudo darwin-rebuild switch --flake .#KangaZero

# NixOS / WSL — Home Manager runs as part of the NixOS system
sudo nixos-rebuild switch --flake .#nixos
```

On first run `vim.pack` fetches everything in the lockfile, and mason installs the
configured LSP servers. Restart once after the initial sync.

> **NixOS:** All LSP servers, formatters, and linters are provided via Nix in
> `neovim.nix` (`home.packages`). Mason finds them on PATH and skips downloading
> prebuilt binaries — necessary on baremetal NixOS where foreign ELF binaries won't
> run. No Mason behaviour changes are needed.

### Live development (no rebuild)

`~/.config/nvim` is the rebuilt store copy, so edits to the source here are only
picked up after a system rebuild. To iterate on the config live, use the `nvim-dev`
shell alias (defined in `hosts/nixos` and `hosts/KangaZero`):

```sh
nvim-dev          # == NVIM_APPNAME=multi-nix/home/modules/common/neovim/config nvim
```

`NVIM_APPNAME` is relative to `$XDG_CONFIG_HOME` (`~/.config`), so it resolves
straight to this working tree — every edit shows on the next launch, no rebuild.
Data/state isolate under `~/.local/share/multi-nix/...`, so the dev session clones
its own plugins once and can't disturb the rebuilt `~/.config/nvim`.

---

## Testing & CI

All checks live in the **`justfile`** so the pre-commit hook and GitHub Actions run
the exact same commands. Requires [`just`](https://github.com/casey/just); `stylua`
and `nvim` (≥ 0.12, stable) on PATH.

```sh
just            # list recipes
just check      # syntax + stylua --check + load (current env) — fast, for local/dev
just ci         # syntax + stylua --check + isolated fresh load — what CI runs
just syntax     # offline parse check of every .lua (no plugins loaded)
just fmt        # auto-format with stylua
just fmt-check  # stylua --check only
just smoke      # headless load in the current env
just load       # headless load in a throwaway XDG env (fresh plugin clone)
```

**What each test does**
- `syntax` — `loadfile()`s every Lua file via `nvim --clean -l scripts/check-syntax.lua`.
  Catches parse errors (e.g. code after `return`, unbalanced braces) with no plugin
  downloads. Hermetic and instant.
- `smoke` / `load` — runs `nvim --headless -c qa!` and fails on any `error`/`E…:`/stack
  trace. `load` isolates `XDG_*` into a tempdir so it clones plugins fresh (CI-grade);
  `smoke` reuses your installed plugins (fast).

### Pre-commit hook

Install once (run from the config dir):

```sh
just install-hooks
```

This symlinks `scripts/hooks/pre-commit` into `.git/hooks/`. It runs `just check`
**only when `home/modules/common/neovim/config/**.lua` files are staged**, so commits
elsewhere in the flake repo are untouched. If `just` isn't installed it falls back to
running the scripts directly.

### GitHub Actions

`.github/workflows/ci.yml` (at the repo root) includes a `check-nvim-config` job that
triggers on every push/PR. It uses `nix shell nixpkgs#neovim` and `nix shell nixpkgs#stylua`
to run the Lua syntax check and stylua fmt check directly — no `just` required in CI.
