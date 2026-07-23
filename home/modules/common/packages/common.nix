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
    # NOTE: These can just be loaded from from said project's flake (shell)
    # nodejs_26
    # pnpm
    # rustup
    # python3
    # just
    # uv
    nerd-fonts.jetbrains-mono
    nh
  ];
}
