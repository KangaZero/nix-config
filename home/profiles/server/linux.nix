# Bare-metal NixOS sibling of ../KangaZero/linux.nix.
#
# Differences vs the WSL (KangaZero) home profile — both WSL-only bits dropped:
#   - no `linux/weston.nix`   (WSL used weston as a Wayland bridge; niri runs natively here)
#   - no `LIBGL_ALWAYS_SOFTWARE = "1"` (real Intel GPU + hardware.graphics; no software GL)
#
# Everything else mirrors KangaZero/linux.nix. Identity (username/git/state) comes from
# ../KangaZero/default.nix via ./default.nix, so this stays a thin desktop-only override.
#
# WHICH profile loads, and the "KangaZero" naming trap:
# This file is loaded two ways, both selecting the profile by the *directory name* `server`
# (the `user` arg), NOT by any hostname:
#   1. Server nixosConfiguration — `lib.mkNixOS { user = "server"; ... }` wires HM via
#      `home/profiles/server/linux.nix`.
#   2. Standalone home output — `lib.mkHome { user = "server"; ... }` (mkHome takes no
#      hostname, only { system, user }) → same file.
# The standalone output is *keyed* `homeConfigurations."KangaZero"` (flake.nix's
# `serverHomeManagerUser`) purely because that is the OS username you activate as
# (`home.username` below resolves to "KangaZero" from userMeta, home dir /home/KangaZero).
# So `home-manager switch --flake .#KangaZero` = the activation TARGET name (KangaZero),
# while the CONTENT is this `server` profile. Two different axes that happen to share names —
# do not "fix" the .#KangaZero key to .#server; it must match the Linux username.
{
  username,
  userMeta,
  assetsDir,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../modules/common/git.nix
    ../../modules/common/direnv.nix
    ../../modules/common/firefox.nix
    ../../modules/common/kitty.nix
    ../../modules/common/neovim/neovim.nix
    ../../modules/common/packages/common.nix
    ../../modules/common/packages/ns-script.nix
    ../../modules/common/shell/zsh-core.nix
    ../../modules/common/oh-my-posh.nix
    ../../modules/common/zellij.nix
    ../../modules/common/zoxide.nix
    ../../modules/common/lazygit.nix
    ../../modules/linux/ollama.nix
    ../../modules/linux/packages.nix
    ../../modules/linux/bash.nix
    ../../modules/linux/shell.nix
    ../../modules/linux/zsh-aliases.nix
    ../../modules/linux/wayland/niri/default.nix
  ];

  programs = {
    kitty.settings = {
      background_image = "${assetsDir}/moon_dark.png";
      background_image_layout = "scaled";
      background_tint = "0.85";
    };
    # Override userMeta.git.personal
    git.settings.user = {
      name = lib.mkForce userMeta.git.work.name;
      email = lib.mkForce userMeta.git.work.email;
    };

    # Idle behaviour is handled entirely by noctalia's built-in Idle service (no swayidle).
    # Merges into the shared noctalia settings from wayland/niri/noctalia.nix (new `idle` key,
    # no clash). Freeform JSON consumed by noctalia at runtime — confirm/adjust in the noctalia
    # Control Center after first boot if the schema differs.
    noctalia.settings.idle = {
      enabled = true;
      lock_timeout = 300; # ~5 min idle → lock
      screen_off_timeout = 600; # ~10 min idle → turn screen off
      respect_inhibitors = true;
    };

  };

  home = {
    inherit username;
    inherit (userMeta) stateVersion;
    homeDirectory = "/home/${username}";
    keyboard.layout = "us";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  # Bare metal launches niri via greetd → `niri --session`, so graphical-session.target
  # fires (unlike the WSL weston bridge). Run a polkit agent bound to it so GUI privilege
  # prompts (e.g. NetworkManager, mounts) get an authentication dialog.
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome authentication agent";
      WantedBy = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
}
