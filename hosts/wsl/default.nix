{ username, ... }:
{
  wsl = {
    enable = true;
    defaultUser = username;
    startMenuLaunchers = true;
  };

  time.timeZone = "Asia/Tokyo";

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "25.05";
}
