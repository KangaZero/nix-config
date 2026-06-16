{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fzf
    yazi
    eza
    bat
    btop
    ripgrep
    fd
    jq
    curl
    gh
    nodejs
    pnpm
    rustup
    python3
    mise
    just
    claude-code
    nerd-fonts.jetbrains-mono
  ];
}
