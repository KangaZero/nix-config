{
  inputs,
  username,
  ...
}:
{
  nix-homebrew = {
    enable = true;
    user = username;
    enableRosetta = true;
    # autoMigrate moves any pre-existing (imperative) Homebrew taps out of the
    # way on activation so nix-homebrew can own /opt/homebrew/Library/Taps with
    # mutableTaps = false. Without it, an existing Taps dir aborts the switch
    # with "An existing /opt/homebrew/Library/Taps is in the way".
    autoMigrate = true;
    taps = {
      "homebrew/core" = inputs.homebrew-core;
      "homebrew/cask" = inputs.homebrew-cask;
      "BarutSRB/tap" = inputs.homebrew-barutsrb-tap;
      "KangaZero/neomouse" = inputs.homebrew-neomouse-tap;
    };
    mutableTaps = false;
    trust.taps = [
      "BarutSRB/tap"
      "KangaZero/neomouse"
    ];
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };
    global = {
      autoUpdate = true;
      brewfile = true;
    };
    # Taps are managed declaratively by nix-homebrew above (mutableTaps = false).
    # Do NOT also set homebrew.taps here — nix-darwin would try to `brew tap`
    # (git clone) into the read-only nix-store-backed Taps dir and fail with
    # "Permission denied".
    casks = [
      "linearmouse"
      "omniwm"
    ];
    brews = [
      "neomouse"
    ];
  };
}
