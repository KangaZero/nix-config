{ pkgs, lib, ... }:
{
  # noctalia uses cliphist + wl-paste internally for clipboard history
  home.packages = with pkgs; [
    noctalia-shell
    cliphist
    wl-clipboard
  ];

  # Config: ~/.config/noctalia/settings.json
  # Path derived from Settings.qml: shellName="noctalia", XDG_CONFIG_HOME fallback ~/.config
  home.file.".config/noctalia/settings.json".text = builtins.toJSON {
    settingsVersion = 0;

    bar = {
      barType = "simple";
      position = "top";
      monitors = [ ];
      density = "default";
      showCapsule = true;
      capsuleOpacity = 1;
      backgroundOpacity = 0.93;
      marginVertical = 4;
      marginHorizontal = 4;
      frameRadius = 12;
      outerCorners = true;
      displayMode = "always_visible";
      widgets = {
        left = [
          { id = "Launcher"; }
          { id = "ActiveWindow"; }
        ];
        center = [
          { id = "Workspace"; }
        ];
        right = [
          { id = "SystemMonitor"; }
          { id = "NotificationHistory"; }
          { id = "Battery"; }
          { id = "Volume"; }
          { id = "ControlCenter"; }
        ];
      };
    };

    general = {
      showChangelogOnStartup = false;
      telemetryEnabled = false;
      enableShadows = true;
      enableBlurBehind = true;
      animationSpeed = 1;
    };

    colorSchemes = {
      darkMode = true;
      predefinedScheme = "Noctalia (default)";
      useWallpaperColors = true;
      generationMethod = "tonal-spot";
      syncGsettings = false;
    };

    wallpaper = {
      enabled = true;
      directory = "~/Wallpapers";
      fillMode = "crop";
      setWallpaperOnAllMonitors = true;
      transitionDuration = 1000;
      transitionType = [ "fade" ];
    };

    appLauncher = {
      terminalCommand = "${lib.getExe pkgs.kitty} -e";
      enableClipboardHistory = true;
      clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
      clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
      sortByMostUsed = true;
      position = "center";
      viewMode = "list";
      showCategories = true;
    };

    notifications = {
      enabled = true;
      location = "top_right";
      lowUrgencyDuration = 5;
      normalUrgencyDuration = 8;
      criticalUrgencyDuration = 0;
    };

    dock.enabled = false;

    noctaliaPerformance = {
      disableWallpaper = false;
      disableDesktopWidgets = true;
    };

    idle.enabled = false;

    nightLight.enabled = false;

    hooks.enabled = false;
  };

  # noctalia launched by niri's `spawn-at-startup` (see wayland/niri/default.nix).
  # No systemd user service: weston bridge runs plain `niri` (not `niri --session`),
  # so graphical-session.target never fires and any unit bound to it stays dead.
}
