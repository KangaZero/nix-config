{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # fzf  # managed by programs.fzf (fzf.nix)
    eza
    # bat  # managed by programs.bat (bat.nix)
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
  ];
}
