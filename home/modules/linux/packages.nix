{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # wget
    openssh
    tldr
    ffmpeg-full
    unzip
    (azure-cli.withExtensions [
      azure-cli-extensions.azure-devops
      (azure-cli-extensions.containerapp.overridePythonAttrs (_: {
        pythonRelaxDeps = [ "kubernetes" ];
      }))
    ])

    # C toolchain for plugins that build native code. No longer needed for
    # nvim-treesitter: its parsers now arrive prebuilt from Nix via
    # programs.neovim.plugins in neovim.nix, so nothing compiles grammars at install
    # time. Still wanted because bare-metal NixOS ships no implicit compiler — gcc's
    # wrapper provides both `gcc` and `cc`, and gnumake covers plugins with a `make`
    # step. (macOS gets `cc` from Xcode CLT, so this stays Linux-only per profile
    # dispatch.)
    gcc
    gnumake
    wl-clipboard
  ];
}
