{ username, ... }:
{
  # nix-darwin ships no `programs.nh`, so darwin uses the home-manager module for
  # the env vars only. Cleaning is deliberately left off here: the HM module can
  # schedule just `nh clean user` (unprivileged launchd *agent*), which never
  # touches /nix/var/nix/profiles/system. The root sweep in
  # modules/darwin/nh-clean.nix does `nh clean all`, which already covers this
  # user's profile — enabling both would put two GCs on the same store lock.
  programs.nh = {
    enable = true;

    # NH_DARWIN_FLAKE. Set the platform-specific variable rather than the generic
    # `flake`, so `nh home` can never be pointed at the darwin attribute by accident.
    darwinFlake = "/Users/${username}/.config/multi-nix";

    clean.enable = false;
  };
}
