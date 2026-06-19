{ hostname, username, ... }:
{
  networking.hostName = hostname;

  home-manager.users.${username}.programs.zsh.shellAliases = {
    ".." = "cd ..";
    "nix-switch" = "sudo darwin-rebuild switch --flake ~/.config/multi-nix#${hostname}";
    "nix-build" = "darwin-rebuild build --flake ~/.config/multi-nix#${hostname}";
    "nix-eval" =
      "nix eval --raw ~/.config/multi-nix#darwinConfigurations.${hostname}.config.system.build.toplevel.outPath";
    # Run nvim against the live in-repo config without a rebuild. NVIM_APPNAME is
    # relative to $XDG_CONFIG_HOME (~/.config), so it resolves straight to the
    # working tree. Data/state isolated under ~/.local/share/multi-nix/... so this
    # dev session can't disturb the rebuilt ~/.config/nvim.
    "nvim-dev" = "NVIM_APPNAME=multi-nix/home/modules/common/neovim/config nvim";
  };
}
