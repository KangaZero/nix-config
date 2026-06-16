{ self, ... }:
{
  nix.enable = false;

  nix.gc = {
    automatic = true;
    interval.Day = 1;
    options = "--delete-older-than 14d";
  };

  security.pam.services.sudo_local.touchIdAuth = true;
  time.timeZone = "Asia/Tokyo";

  power.sleep = {
    allowSleepByPowerButton = true;
    computer = 10;
  };

  system = {
    stateVersion = 6;
    configurationRevision = self.rev or self.dirtyRev or null;
    startup.chime = false;

    defaults = {
      loginwindow = {
        GuestEnabled = false;
        DisableConsoleAccess = true;
      };
      spaces.spans-displays = true;
      dock.expose-group-apps = true;
      magicmouse.MouseButtonMode = "OneButton";
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
      screencapture.location = "~/Documents/";
      trackpad.Clicking = true;
      dock = {
        autohide = true;
        launchanim = false;
        magnification = false;
        mru-spaces = false;
        orientation = "right";
        show-recents = false;
        tilesize = 36;
        persistent-apps = [
          "/Applications/Nix Apps/kitty.app"
          "/Applications/Nix Apps/Firefox Developer Edition.app"
        ];
      };
      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };
      controlcenter = {
        BatteryShowPercentage = true;
        Bluetooth = true;
        Display = false;
        FocusModes = false;
        NowPlaying = true;
        Sound = true;
      };
      NSGlobalDomain = {
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
      };
    };
  };
}
