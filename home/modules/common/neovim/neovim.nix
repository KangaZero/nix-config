{ pkgs, lib, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    # Lets neovim use the default ~/.config/nvim/init.lua — config managed outside Nix
    sideloadInitLua = true;
  };

  xdg.configFile."nvim" = {
    # Exclude nvim-pack-lock.json: it is runtime-owned by vim.pack (see
    # nvimPackLock below). Managing it here makes home-manager's checkLinkTargets
    # abort the whole activation once a prior switch leaves a writable copy in place.
    source = lib.cleanSourceWith {
      src = ./config;
      filter = path: _type: baseNameOf path != "nvim-pack-lock.json";
    };
    recursive = true;
  };

  # Generated so the Neovim runtime path stays correct after every `nixos-rebuild switch`.
  xdg.configFile."nvim/.luarc.json".text = ''
    {
      "$schema": "https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json",
      "runtime": { "version": "LuaJIT" },
      "workspace": {
        "library": [
          "${pkgs.neovim-unwrapped}/share/nvim/runtime/lua",
          "''${3rd}/luv/library"
        ],
        "checkThirdParty": false
      },
      "diagnostics": {
        "globals": ["vim"]
      }
    }
  '';

  # nvim-pack-lock.json is owned by vim.pack at runtime (nvim 0.12 rewrites it on
  # startup), so home-manager must NOT manage it — a read-only store symlink causes
  # EROFS, and re-linking it aborts activation via checkLinkTargets. It is filtered
  # out of the source above; seed it from the committed (pinned) lock only when
  # absent, writable, then leave it entirely to nvim.
  home.activation.nvimPackLock = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    lockFile="$HOME/.config/nvim/nvim-pack-lock.json"
    if [ ! -e "$lockFile" ]; then
      $DRY_RUN_CMD install -m 0644 -D ${./config/nvim-pack-lock.json} "$lockFile"
    fi
  '';

  # LSP servers, formatters, and linters on PATH for nvim to spawn directly.
  # On NixOS (`/etc/NIXOS` present) lsp.lua skips Mason's `ensure_installed`, so
  # Mason downloads nothing — these packages ARE the toolchain. The node-based
  # servers (vtsls, vscode-langservers-extracted, tailwindcss, pyright, bashls)
  # are wrapped by nixpkgs with a store-pinned node, so no global `nodejs` is
  # needed. Off NixOS, Mason installs everything itself (and would need node).
  home.packages = with pkgs; [
    # LSP servers
    lua-language-server
    bash-language-server
    pyright
    ruff
    clang-tools # provides clangd
    vtsls
    typescript-go # `tsgo` — native Go TS (TS 7) LSP, run alongside vtsls for A/B
    vscode-langservers-extracted # cssls, jsonls, eslint, html
    biome
    tailwindcss-language-server
    # If rust is needed add `rustup`
    # rust-analyzer omitted — rustup provides it via `rustup component add rust-analyzer`
    nixd

    # Formatters
    stylua
    nixfmt
  ];
}
