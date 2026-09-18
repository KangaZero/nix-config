# ≈ lua/lsp.lua
#
# No mason equivalent and none needed: nvf resolves every server from nixpkgs at
# build time, which is what lsp.lua already does on NixOS via is_nixos.
#
# TS caveat: vim.languages.typescript.lsp.servers only accepts
# typescript-language-server | deno | typescript-go | emmet-ls. There is no vtsls
# here, and `typescript-go` is stale — its preset still references
# pkgs.typescript-go, which nixpkgs renamed to `typescript` (TS 7, binary `tsc`).
# So this uses typescript-language-server. The real config's `tsc` setup is ahead
# of nvf on this point.
{
  config.vim = {
    lsp = {
      enable = true;
      lspkind.enable = true;
      trouble.enable = true;
    };

    languages = {
      enableTreesitter = true;
      enableFormat = true;
      enableExtraDiagnostics = true;

      nix = {
        enable = true;
        lsp.servers = [ "nixd" ];
        format.type = [ "nixfmt" ];
      };

      typescript = {
        enable = true;
        lsp.servers = [ "typescript-language-server" ];
        format.type = [ "biome" ];
      };

      tsx.enable = true;

      lua.enable = true;
      bash.enable = true;
      python.enable = true;
      clang.enable = true;
      css.enable = true;
      html.enable = true;
      json.enable = true;
      yaml.enable = true;
    };
  };
}
