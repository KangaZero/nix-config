{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    # Lets neovim use the default ~/.config/nvim/init.lua — config managed outside Nix
    sideloadInitLua = true;
  };

  xdg.configFile."nvim" = {
    source = ./config;
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

  # LSP servers, formatters, and linters on PATH so Mason uses these
  # instead of downloading prebuilt binaries (which break on baremetal NixOS).
  home.packages = with pkgs; [
    # LSP servers
    lua-language-server
    bash-language-server
    pyright
    ruff
    clang-tools # provides clangd
    vtsls
    vscode-langservers-extracted # cssls, jsonls, eslint, html
    biome
    tailwindcss-language-server
    # rust-analyzer omitted — rustup provides it via `rustup component add rust-analyzer`
    nixd

    # Formatters
    stylua
    nixfmt
  ];
}
