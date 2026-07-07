# Bare-metal NixOS laptop `server` — home-manager-first desktop.
#
# System-level (root / reboot) config only; everything user-facing lives in the
# server home profile (home/profiles/server/linux.nix) and the shared niri/noctalia
# home modules. Mirrors the WSL host's system bits minus WSL, plus a real desktop:
# greetd + noctalia-greeter → niri + noctalia, PipeWire audio, CUPS, Bluetooth,
# power-profiles-daemon, Intel graphics.
#
# Top-level attrs are consolidated (one `programs`/`services`/`security`/… block
# each) to satisfy statix's "repeated key" lint; section comments mark the intent.
{
  inputs,
  username,
  hostname,
  pkgs,
  ...
}:
{
  imports = [
    inputs.noctalia-greeter.nixosModules.default
  ];

  # ─── Boot ──────────────────────────────────────────────────────────────────
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # ─── Networking / identity ───────────────────────────────────────────────────
  networking = {
    hostName = hostname;
    networkmanager.enable = true; # noctalia Control Center = the UI
  };

  # ─── Locale / time ────────────────────────────────────────────────────────────
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  # ─── User ──────────────────────────────────────────────────────────────────────
  # mkNixOS already sets isNormalUser + wheel; these definitions merge (extraGroups
  # lists concatenate).
  users.users.${username} = {
    extraGroups = [
      "networkmanager"
      "video"
      "audio"
      "input"
    ];
    shell = pkgs.zsh;
    # See https://nixos.wiki/wiki/SSH_public_key_authentication
    openssh.authorizedKeys.keys = [
      # paste output of: cat ~/.ssh/id_ed25519.pub
      "ssh-ed25519 REPLACE_ME KangaZero"
    ];
  };

  # ─── Hardware: audio (PipeWire), bluetooth, Intel graphics ───────────────────────
  hardware = {
    bluetooth = {
      enable = true; # noctalia = the UI
      powerOnBoot = true;
    };
    # enable32Bit comes from the shared modules/nixos/graphics.nix extraModule.
    graphics = {
      enable = true;
      extraPackages = [ pkgs.intel-media-driver ];
    };
  };

  # ─── security: rtkit (PipeWire), polkit, gnome-keyring PAM ───────────────────────
  security = {
    rtkit.enable = true;
    polkit.enable = true;
    pam.services.greetd.enableGnomeKeyring = true;
  };

  # ─── services ─────────────────────────────────────────────────────────────────
  services = {
    # SSH (key-only), mirrors the WSL host.
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    # Audio: PipeWire replaces PulseAudio.
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Battery: Allows Noctalia to render Battery widget
    upower.enable = true;

    # Power/brightness: power-profiles-daemon (noctalia-integrated), NOT TLP — they conflict.
    power-profiles-daemon.enable = true;

    # Printing (CUPS), carried over from the old box.
    printing.enable = true;

    # Secrets: gnome-keyring unlocked at login by the greetd PAM hook above.
    gnome.gnome-keyring.enable = true;
  };

  # ─── Fonts ──────────────────────────────────────────────────────────────────────
  fonts = {
    packages = [
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-cjk-serif # provides "Noto Serif CJK JP" referenced in defaultFonts.serif
      pkgs.noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      serif = [ "Noto Serif CJK JP" ];
      sansSerif = [ "Noto Sans CJK JP" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # ─── XDG portals ───────────────────────────────────────────────────────────────
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
  };

  # ─── programs ──────────────────────────────────────────────────────────────────
  programs = {
    zsh.enable = true; # makes pkgs.zsh a valid login shell

    # GnuPG agent, carried over from the old box.
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # Login: greetd via noctalia-greeter. The module wires up services.greetd; the
    # greeter lists the niri session provided by programs.niri.enable (the
    # modules/nixos/wayland/niri.nix extraModule).
    noctalia-greeter = {
      enable = true;
      settings = {
        cursor = {
          theme = "Bibata-Modern-Classic";
          size = 24;
          path = "${pkgs.bibata-cursors}/share/icons";
        };
        keyboard.layout = "us";
      };
    };
  };

  # ─── System packages ─────────────────────────────────────────────────────────────
  environment.systemPackages = [ pkgs.brightnessctl ];

  # ─── Nix GC ──────────────────────────────────────────────────────────────────────
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "26.11";
}
