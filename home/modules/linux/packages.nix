{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wget
    openssh
    tldr
    ffmpeg-full
    unzip
    (azure-cli.withExtensions [ azure-cli-extensions.azure-devops ])

    # Toolchain for nvim-treesitter (main): parsers are compiled from C source at
    # install time via `cc`. Bare-metal NixOS ships no implicit compiler, so nvim
    # loads but every treesitter-dependent plugin fails. gcc's wrapper provides
    # both `gcc` and `cc`; gnumake covers plugins with a `make` build step.
    # (macOS gets `cc` from Xcode CLT, so this stays Linux-only per profile dispatch.)
    gcc
    gnumake
    wl-clipboard
  ];
}
