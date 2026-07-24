{
  username,
  pkgs,
  lib,
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

  # PostgreSQL 18 — local dev DB (ClaudeCode4BTP moved HANA -> Postgres, DD-015).
  # The role + database are created declaratively; the PASSWORD is set
  # out-of-band and is deliberately NOT in this file — this repo is PUBLIC, so a
  # committed credential would leak. After `nixos-rebuild switch`, run once:
  #   sudo -u postgres psql -c "ALTER ROLE ccui PASSWORD 'your-dev-password';"
  # then put that same value in the app's .env.local as CCUI_DB_PASSWORD
  # (with CCUI_DB_USER=ccui, CCUI_DB_NAME=ccui).
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    # Listen beyond the unix socket so both native dev (localhost:5432) and
    # Docker containers (via host.docker.internal / the docker bridge) can
    # connect. WSL isn't exposed to the LAN, so binding all interfaces is safe.
    settings.listen_addresses = lib.mkForce "*";
    ensureDatabases = [ "ccui" ];
    ensureUsers = [
      {
        name = "ccui";
        ensureDBOwnership = true; # owns the `ccui` db -> can create its tables
      }
    ];
    # peer for the local socket; scram password auth for TCP (so the app logs in
    # with CCUI_DB_PASSWORD). 172.16/12 covers the Docker bridge range on WSL —
    # widen/narrow if your bridge subnet differs.
    authentication = lib.mkForce ''
      # TYPE  DATABASE  USER  ADDRESS         METHOD
      local   all       all                   peer
      host    all       all   127.0.0.1/32    scram-sha-256
      host    all       all   ::1/128         scram-sha-256
      host    all       all   172.16.0.0/12   scram-sha-256
    '';
  };
  # Open 5432 for container -> host connections (WSL is loopback-only anyway).
  networking.firewall.allowedTCPPorts = [ 5432 ];
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
