{ lib, username, ... }:
{
  # nh replaces `nix.gc` + `nix-collect-garbage`. Two reasons it wins:
  #  - `nh clean all` sweeps every profile (system, home-manager, per-user) plus
  #    gcroots and then runs `nix store gc`; `nix.gc` only walks the profile dirs.
  #  - it takes a generation floor (`--keep`) alongside the age cutoff, so a long
  #    gap between rebuilds can't strand the host on a single rollback target.
  # `nix.gc.automatic` must stay off everywhere: the module only warns on the
  # conflict, it does not disable one side, so both timers would race the store.
  programs.nh = {
    enable = true;

    # Exported as NH_FLAKE, so `nh os switch` / `nh clean` need no flake argument
    # from any cwd. Directory, not a .nix file — the module asserts on the suffix.
    flake = "/home/${username}/.config/multi-nix";

    clean = {
      enable = true;

      # mkDefault on both: a host that wants a different window overrides them in
      # hosts/<h>/default.nix. Without it the two definitions sit at equal
      # priority and the merge is a hard eval error, not a silent win.
      dates = lib.mkDefault "weekly";

      # Retention policy. Non-negotiable to set: nh's own defaults are
      # `--keep 1 --keep-since 0h`, so leaving this empty is *more* destructive
      # than the nix-collect-garbage setup it replaces.
      # --keep 3 is the generation floor (current + two rollback targets);
      # --keep-since is the age cutoff. Whichever keeps more wins.
      extraArgs = lib.mkDefault "--keep 3 --keep-since 7d";
    };
  };
}
