{ hostname, username, ... }:
{
  networking.hostName = hostname;

  home-manager.users.${username}.programs.zsh.shellAliases = {
    ".." = "cd ..";
    "nix-switch" = "sudo darwin-rebuild switch --flake ~/.config/multi-nix#${hostname}";
    "nix-build" = "darwin-rebuild build --flake ~/.config/multi-nix#${hostname}";
    "nix-eval" =
      "nix eval --raw ~/.config/multi-nix#darwinConfigurations.${hostname}.config.system.build.toplevel.outPath";
  };
}
