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

  # WSL has no login session to keep `systemd --user` (and its dbus socket) alive,
  # so `nixos-rebuild switch` fails to reload user units ("/run/user/1000/bus:
  # Connection refused"). Lingering starts the user manager at boot, persistently.
  users.users.${username} = {
    linger = true;
    extraGroups = [ "uinput" ];
    # See https://nixos.wiki/wiki/SSH_public_key_authentication
    openssh.authorizedKeys.keys = [
      # paste output of: cat ~/.ssh/id_ed25519.pub
      "ssh-ed25519 REPLACE_ME KangaZero"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  environment.variables.EDITOR = "nvim";

  # INFO: No longer in use, migrated over nvim config to this repo !!! finally
  # WARNING: Very bad to do this, will eventually have a truly declarative way to add in my nvim config
  # system.activationScripts.rootNvimConfig = ''
  #   mkdir -p /root/.config
  #   ln -sfn /home/${username}/Documents/dotfiles-mac/nvim-min /root/.config/nvim
  # '';
  #
  home-manager.users.${username}.programs.zsh.shellAliases = {
    edit-nix = "cd /home/${username}/.config/multi-nix && nvim flake.nix";
    home-switch = "home-manager switch --flake /home/${username}/.config/multi-nix#${username}";
    nix-switch = "sudo nixos-rebuild switch --flake /home/${username}/.config/multi-nix#${hostname}";
    nh-switch = "nh os switch /home/${username}/.config/multi-nix#${hostname}";
    nh-build = "nh os build /home/${username}/.config/multi-nix#${hostname}";
    # Run nvim against the live in-repo config without a rebuild. NVIM_APPNAME is
    # relative to $XDG_CONFIG_HOME (~/.config), so it resolves straight to the
    # working tree. Data/state isolated under ~/.local/share/multi-nix/... so this
    # dev session can't disturb the rebuilt ~/.config/nvim.
    nvim-dev = "NVIM_APPNAME=multi-nix/home/modules/common/neovim/config nvim";
  };

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      git
      neovim
      weston
      ;
  };

  system.stateVersion = "26.11";
}
