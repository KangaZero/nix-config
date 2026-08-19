{ lib, pkgs, ... }:
{
  # Why this is hand-rolled: nix-darwin ships neither `programs.nh` nor a `nix.gc`
  # option, and `nix.enable = false` here anyway (Determinate installer owns the
  # daemon), so nothing prunes the store on macOS out of the box.
  #
  # This runs as **root** on purpose. The home-manager `programs.nh.clean` agent is
  # unprivileged and can only do `nh clean user`; only root can prune
  # /nix/var/nix/profiles/system, which is where darwin-rebuild generations live.
  # Keep clean scheduling in exactly one place — see home/modules/darwin/nh.nix.
  launchd.daemons.nh-clean = {
    script = "exec ${lib.getExe pkgs.nh} clean all --keep 3 --keep-since 7d";

    # nh shells out to `nix store gc`. The Determinate daemon's nix lives in the
    # default profile, not the store, so PATH has to be set explicitly — a launchd
    # daemon starts with a near-empty environment.
    environment.PATH = "/nix/var/nix/profiles/default/bin:/usr/bin:/bin:/usr/sbin:/sbin";

    serviceConfig = {
      # Sundays 15:00. Never RunAtLoad: a GC racing an activation would fight the
      # rebuild for the store lock.
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 15;
          Minute = 0;
        }
      ];
      StandardOutPath = "/var/log/nh-clean.log";
      StandardErrorPath = "/var/log/nh-clean.log";
    };
  };
}
