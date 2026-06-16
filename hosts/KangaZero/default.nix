{ hostname, username, ... }:
{
  networking.hostName = hostname;

  home-manager.users.${username}.programs.zsh.shellAliases = {
    ".." = "cd ..";
    "nix-switch" = "sudo darwin-rebuild switch --flake ~/.config/nix-config#KangaZero";
    "nix-build" = "darwin-rebuild build --flake ~/.config/nix-config#KangaZero";
    "nix-eval" = "nix eval --raw ~/.config/nix-config#darwinConfigurations.KangaZero.config.system.build.toplevel.outPath";
  };
}
