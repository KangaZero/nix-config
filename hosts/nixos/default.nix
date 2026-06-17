{
  username,
  hostname,
  pkgs,
  ...
}:
{
  wsl = {
    enable = true;
    defaultUser = username;
    useWindowsDriver = true;
    startMenuLaunchers = true;
    ssh-agent.enable = false;
  };

  time.timeZone = "Asia/Tokyo";

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  environment.variables.EDITOR = "nvim";

  # WARNING: Very bad to do this, will eventually have a truly declarative way to add in my nvim config
  system.activationScripts.rootNvimConfig = ''
    mkdir -p /root/.config
    ln -sfn /home/${username}/Documents/dotfiles-mac/nvim-min /root/.config/nvim
  '';

  home-manager.users.${username}.programs.zsh.shellAliases = {
    edit-nix = "cd /home/${username}/.config/multi-nix && nvim flake.nix";
    home-switch = "home-manager switch --flake /home/${username}/.config/multi-nix#${username}";
    nix-switch = "sudo nixos-rebuild switch --flake /home/${username}/.config/multi-nix#${hostname}";
  };

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      git
      neovim
      nixd
      weston
      ;
  };

  system.stateVersion = "26.11";
}
