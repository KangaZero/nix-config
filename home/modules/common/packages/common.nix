{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fzf
    eza
    bat
    btop
    ripgrep
    fd
    jq
    curl
    gh
    nodejs_26
    pnpm
    rustup
    python3
    mise
    just
    nerd-fonts.jetbrains-mono
    nh
  ];
}
