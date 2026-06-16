{
  inputs,
  username,
  config,
  ...
}:
{
  nix-homebrew = {
    enable = true;
    user = username;
    enableRosetta = true;
    autoMigrate = false;
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
    taps = builtins.filter (t: t != "homebrew/core" && t != "homebrew/cask") (
      builtins.attrNames config.nix-homebrew.taps
    );
    casks = [
      "linearmouse"
      "omniwm"
    ];
    brews = [
      "neomouse"
    ];
  };
}
