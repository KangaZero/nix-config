{
  username,
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

  virtualisation.docker.enable = true;
  # WSL has no login session to keep `systemd --user` (and its dbus socket) alive,
  # so `nixos-rebuild switch` fails to reload user units ("/run/user/1000/bus:
  # Connection refused"). Lingering starts the user manager at boot, persistently.
  users.users.${username} = {
    linger = true;
    extraGroups = [
      "uinput"
      "docker"
    ];
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

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    settings.auto-optimise-store = true;
  };

  environment.variables.EDITOR = "nvim";

  # No system-level packages: git + neovim are provided per-user by home-manager
  # (home/modules/common/git.nix and neovim/neovim.nix); weston was dropped when
  # WSL went CLI-only.

  system.stateVersion = "26.11";
}
