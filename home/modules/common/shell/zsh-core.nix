{ pkgs, ... }:
{
  imports = [ ./nixpkgs.nix ];

  home.packages = [ pkgs.zsh-vi-mode ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
    oh-my-zsh = {
      enable = true;
      plugins = [ "history" ];
    };
    history = {
      size = 10000;
      ignoreAllDups = true;
      path = "$HOME/.cache/zsh/history";
    };
    initContent = ''
      source ${./shell-functions.sh}
    '';
  };
}
