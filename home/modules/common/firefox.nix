{ pkgs, ... }:
let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  # deadnix: skip
  lock-true = {
    Value = true;
    Status = "locked";
  };
  setDefault = v: {
    Value = v;
    Status = "default";
  };
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      DisablePocket = true;
      SearchBar = "unified";
      Homepage = {
        URL = "https://search.nixos.org";
        StartPage = "homepage";
        Locked = true;
      };
      Preferences = {
        "extensions.pocket.enabled" = lock-false;
        "browser.newtabpage.pinned" = { Value = ""; Status = "locked"; };
        "browser.topsites.contile.enabled" = lock-false;
        "browser.newtabpage.activity-stream.showSponsored" = lock-false;
        "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
        "browser.aboutConfig.showWarning" = setDefault false;
        "browser.compactmode.show" = setDefault true;
        "widget.use-xdg-desktop-portal.file-picker" = setDefault 1;
        "signon.rememberSignons" = setDefault true;
        "browser.cache.disk.enable" = setDefault true;
        "widget.disable-workspace-management" = setDefault false;
        "mousewheel.default.delta_multiplier_x" = setDefault 20;
        "mousewheel.default.delta_multiplier_y" = setDefault 20;
        "mousewheel.default.delta_multiplier_z" = setDefault 20;
      };
      ExtensionSettings = {
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };
}
