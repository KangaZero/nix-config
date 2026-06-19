{ pkgs, ... }:
{
  home = {
    # noctalia uses cliphist + wl-paste internally for clipboard history
    packages = with pkgs; [
      noctalia-shell
      cliphist
      wl-clipboard
    ];

    pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    file.".config/noctalia/settings.json".source = ./noctalia.json;
  }; # home

  # noctalia launched by niri's `spawn-at-startup` (see wayland/niri/default.nix).
  # No systemd user service: weston bridge runs plain `niri` (not `niri --session`),
  # so graphical-session.target never fires and any unit bound to it stays dead.
}
