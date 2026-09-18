# nvf — alternative editor

A declarative Neovim built with [nvf](https://github.com/notashelf/nvf), exposed as a
flake package rather than installed into a profile.

```bash
nix run .#nvf                    # from this repo
nix run ~/.config/multi-nix#nvf  # from anywhere
```

This is an **alternative** to `programs.neovim` (`home/modules/common/neovim/`), not a
replacement for it: the same setup expressed declaratively in Nix instead of Lua. It
exists so a working Nix-native path is already there if I ever want to configure Neovim
that way. Both editors are installed side by side and share nothing at runtime.

> [!IMPORTANT]
> **This tree started as a mirror of the primary config and will drift from it.**
>
> The file layout and settings were ported one-for-one from
> `home/modules/common/neovim/config/`, but it is a snapshot, not a sync. Divergence is
> expected and in places deliberate:
>
> - nvf has no module for some plugins, and no way to express others at all — see
>   [Portability status](#portability-status) for the current tally.
> - Changes to the primary config do not propagate here. When the two disagree, the
>   primary config is correct and this one is stale.
> - A few settings differ on purpose where nvf's option is better or its enum leaves no
>   choice (the TypeScript server, for one).
>
> ⚠️ I am far less fluent in nvf than in plain Lua, and this tree was written with heavy
> AI assistance. It builds and has been smoke-tested, but it is experimental — not a
> reference for idiomatic nvf.

## Why it is a flake package, not `programs.nvf`

nvf's home-manager module does `home.packages = [ cfg.finalPackage ]`, and nvf's
binary is also `bin/nvim` — mnw wraps `$out/bin/nvim`, then symlinks any aliases
onto it. That collides with `programs.neovim`.

Worse, the collision may not error: mnw sets `priority = neovim.meta.priority - 2`,
and `home.packages` builds through `buildEnv`, which *resolves* priority collisions
silently. You could end up with nvf's `nvim` as your `nvim` and no warning.

As a `packages` output it never enters a profile, so the question does not arise.
`viAlias` / `vimAlias` are off anyway (`core.nix`) so nothing claims `vi` / `vim`.

Runtime state needs no special handling: mnw sets `appName = "nvf"`, so this reads
`~/.config/nvf` and writes `~/.local/{share,state}/nvf` and `~/.cache/nvf`.

## File layout

Mirrors `home/modules/common/neovim/config/` one-for-one.

| here | there |
| --- | --- |
| `default.nix` | `init.lua` — entry point, lists modules in the same order |
| `core.nix` | `lua/core.lua` |
| `lsp.nix` | `lua/lsp.lua` |
| `options.nix` | `lua/options.lua` |
| `colorscheme.nix` | `lua/colorscheme.lua` |
| `statusline.nix` | `lua/ui/statusline.lua` |
| `autocmds.nix` | `lua/autocmds.lua` |
| `keymaps.nix` | `lua/keymaps.lua` |
| `plugins/default.nix` | `lua/plugins/init.lua` |
| `plugins/*.nix` (17) | `lua/plugins/*.lua` |
| `dashboard-logo.txt` | inline in `lua/plugins/dashboard.lua` |

Two deliberate asymmetries: the real config's `lua/plugins/otter.lua` has no
`plugins/otter.nix` here (otter is a first-class nvf option, so it lives in `lsp.nix`),
and `plugins/milli.nix` exists here while `milli.nvim` has been pruned from the real
config's lock.

`nvf.lib.neovimConfiguration` calls `lib.evalModules`, so each file is a real
nixpkgs module and `imports` composes them the way `require()` does. Unlike
`require()`, order does not matter — options merge rather than execute in sequence.
The ordering is kept only so the two trees read alike.

## Portability status

All option paths below were derived from the nvf source
(`grep -rhoE "options\.vim(\.[a-zA-Z0-9_-]+)+" <src>/modules | sort -u`) and the
declaring module read before use — not guessed.

### Fully declarative

| real config | nvf option |
| --- | --- |
| `lua/options.lua` | `vim.options` (freeform submodule), plus curated `lineNumberMode`, `searchCase`, `preventJunkFiles`, `undoFile.enable` |
| `lua/autocmds.lua` | `vim.autocmds` / `vim.augroups`, `callback` via `mkLuaInline` |
| `lua/keymaps.lua` | `vim.keymaps` (52 bindings) |
| `lua/core.lua` | `vim.treesitter` (`enable`, `fold`), `vim.treesitter.textobjects`, `vim.ui.nvim-highlight-colors`, and `viAlias`/`vimAlias = false` |
| diagnostics config | `vim.diagnostics.config` |
| `plugins/otter.lua` | `vim.lsp.otter-nvim` — `handle_leading_whitespace`, plus a `<leader>lo` toggle. Set in `lsp.nix`, not `plugins/` |
| `plugins/telescope.lua` | `vim.telescope` — `setupOpts`, `mappings`, `extensions` (fzf-native built by Nix). Carries no per-picker `theme`, so pickers inherit `layout_strategy = "horizontal"` with `preview_width = 0.75`; adding a `theme` silently overrides that |
| `plugins/completion.lua` | `vim.autocomplete.blink-cmp.setupOpts` |
| `plugins/flash.lua` | `vim.utility.motion.flash-nvim.setupOpts` |
| `plugins/snacks.lua` | `vim.utility.snacks-nvim.setupOpts` |
| `plugins/yazi.lua` | `vim.utility.yazi-nvim.setupOpts` |
| `plugins/conform.lua` | `vim.formatter.conform-nvim.setupOpts.formatters_by_ft` |
| `plugins/dashboard.lua` | `vim.dashboard.dashboard-nvim.setupOpts` |
| `plugins/grug-far.lua` | `vim.utility.grug-far-nvim` |
| `plugins/which-key.lua` | `vim.binds.whichKey` |
| `plugins/markview.lua` | `vim.languages.markdown.extensions.markview-nvim` |
| `plugins/ai.lua` | `vim.assistant.copilot` (kept disabled — it is commented out in the real config) |
| mason / mason-lspconfig | not needed; nvf resolves servers from nixpkgs, as `lsp.lua` already does on NixOS |

`setupOpts` is freeform (`lib/types/plugins.nix`: `freeformType = anything`), and
Lua closures pass through `lib.generators.mkLuaInline`, so plugin config that is
genuinely Lua (blink's `draw.components`, flash's `search.exclude` predicate,
dashboard's `shortcut` actions) still ports — as embedded Lua rather than as Nix.

### Wired via `vim.extraPlugins`

No nvf module exists for these, so each is added as a package plus a `setup` Lua
string, ordered with the `after` DAG field.

| plugin | package |
| --- | --- |
| nvim-hlslens | `pkgs.vimPlugins.nvim-hlslens` |
| tiny-inline-diagnostic.nvim | `pkgs.vimPlugins.tiny-inline-diagnostic-nvim` |
| opencode.nvim | `pkgs.vimPlugins.opencode-nvim` |
| avante.nvim | `pkgs.vimPlugins.avante-nvim` |
| friendly-snippets | `pkgs.vimPlugins.friendly-snippets` — package only, no `setup`: blink's `snippets` source reads them off the runtimepath |
| milli.nvim | hand-packaged with `pkgs.vimUtils.buildVimPlugin` (not in nixpkgs) |
| nekonight.nvim | hand-packaged; not in nvf's theme enum, so `vim.theme.enable = false` |

Both hand-packaged plugins pin the same revision as `nvim-pack-lock.json`, so the
two editors render identically. nekonight needs
`nvimSkipModules = [ "nekonight.extra.fzf" "nekonight.docs" ]` because nixpkgs
require-checks every Lua module and those two optional extras pull deps the
colorscheme does not need; milli needed no skips.

### Not ported

| what | why |
| --- | --- |
| `lua/ui/statusline.lua` | nvf ships lualine only. lualine (`theme = "auto"`) stands in. |
| `lua/custom/{zen,safemode,terminal}.lua` | No modules. Would ride along as strings in `luaConfigRC` — relocation, not porting. Their `<leader>zz` / `<leader>ts` / `<C-/>` bindings are therefore absent. |
| `lua/util.lua` case converters | No equivalent; `<leader>c{k,P,c,s}` absent. |
| `<leader>gg` lazygit float | Depends on `util.create_popup_term_win`. |
| `<leader>p` | `vim.pack.update` — nvf has no vim.pack. |
| ~50 `BlinkCmp*` highlight groups | Hand-tuned to nekonight's palette, plus a `ColorScheme` autocmd to reapply them. ~60 lines of embedded Lua for no declarative gain. |
| Telescope highlight overrides | Same reasoning — the real config repaints Telescope in a Catppuccin Macchiato palette from a `ColorScheme` autocmd. |
| treesitter-textobjects keymaps | 41 manual bindings; nvf's `vim.treesitter.textobjects` ships its own. |
| `after/queries/*.scm` | No option path for treesitter query overlays. |
| `vim.pack` + `nvim-pack-lock.json` | Structurally incompatible. nvf uses mnw, which builds `$out/pack/mnw/{start,opt}` at derivation time; plugins are pinned by nvf's npins plus `flake.lock`. No runtime lockfile, no runtime updates. |

### Gotchas worth remembering

- **A top-level `return` in any `extraPlugins` setup truncates the whole config.**
  nvf concatenates every setup into one `init.lua`, so avante's `if not Darwin then
  return end` guard silently killed every section after it — the nekonight
  colorscheme, all LSP setup, and the mappings block. The body is wrapped in an
  immediately-invoked function to contain the `return`. Symptom to watch for:
  `vim.g.colors_name == nil` with no error message.
- **`timeoutlen` must be written as `tm`.** nvf declares `tm` (default 500) in
  `modules/wrapper/rc/options.nix`; setting `timeoutlen` emits a second key for the
  same option and nvf's declared one wins.
- **Renamed options must be avoided**, e.g. `vim.statusline.lualine.theme` →
  `setupOpts.options.theme`. `nix eval` prints these as evaluation warnings.
- **Keep the `# lua` hints.** 17 of them across 9 files mark the embedded-Lua strings so
  nvim-treesitter's nix `injections.scm` treats those regions as Lua and `otter.nvim` can
  hand them to `lua_ls`. They look like stray comments and are easy to "tidy" away —
  deleting one costs you LSP on that block. The hint must sit **immediately** before the
  `''`:

  ```nix
  setup = # lua
    ''
      require("nekonight").setup({})
    '';

  callback = lib.generators.mkLuaInline # lua
    ''
      function() vim.hl.on_yank() end
    '';
  ```

  `= # lua` placed ahead of `mkLuaInline ''…''` does **not** match — the comment has to be
  adjacent to the string node itself. `nixfmt` preserves the working placement.

### TypeScript: the real config is ahead

`vim.languages.typescript.lsp.servers` is a hard enum:

```
typescript-language-server | deno | typescript-go | emmet-ls
```

- No `vtsls` (`vim.lsp.presets.vtsls` exists at the presets level but is not
  selectable for the typescript language module).
- `typescript-go` is stale — its preset still references `pkgs.typescript-go`, which
  nixpkgs renamed to `typescript` (TS 7, binary `tsc`, serves LSP via
  `--lsp --stdio`).

So `lsp.nix` uses `typescript-language-server`, the older JS implementation. The real
config's `tsc` setup is better; do not treat this tree as a reference for it.

## Bottom line

Every plugin the real config actually loads is present here — most through first-class
options, the rest through `vim.extraPlugins`. One omission is deliberate:
`blink-copilot` is absent because it is fully commented out in the real config (as is
`ai.lua` in its entirety), so leaving it out *is* parity. `friendly-snippets` was a
genuine gap and is now wired in `plugins/completion.nix`.

What does not survive is the hand-written Lua — the statusline, the `custom/` modules,
the `util.lua` helpers, the 48 `BlinkCmp*` and Telescope highlight overrides — plus the
`vim.pack` runtime-lockfile workflow and `after/queries/`. Those are the parts most
specific to this config, and the ones a framework cannot type.

So this works as a standing alternative but a poor wholesale migration target: that
remainder would be rewritten into Nix strings, losing `lua-ls` while editing it, for no
capability gain.
Keep the primary config on `programs.neovim`.

## Verifying a change

```bash
nix eval .#packages.x86_64-linux.nvf.drvPath   # type-checks the module tree
nix build .#packages.x86_64-linux.nvf          # build
nix run .#nvf                                  # run it
```

`nvf-print-config-path` in the built package prints the generated `init.lua` in the
store — the fastest way to see what a set of options actually compiled into.
