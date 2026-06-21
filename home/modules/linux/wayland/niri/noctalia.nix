# v5: uses the noctalia home-manager module (inputs.noctalia.homeModules.default).
#     niri spawns `noctalia` (see default.nix spawn-at-startup).
#
# To revert to v4 instead:
#   - Remove the `imports` and `programs.noctalia` blocks below.
#   - Add packages = with pkgs; [ noctalia-shell cliphist wl-clipboard ];
#   - Add home.file.".config/noctalia/settings.json".source = ./noctalia.json;
#   - In default.nix, change spawn-at-startup "noctalia" → "noctalia-shell"
{ pkgs, inputs, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    settings = {
      backdrop = {
        blur_intensity = 0.1;
        enabled = true;
      };

      bar = {
        order = [ "default" ];
        default = {
          auto_hide = true;
          background_opacity = 0.0;
          border = "on_hover";
          capsule = true;
          capsule_border = "outline";
          capsule_foreground = "tertiary";
          capsule_thickness = 0.75;
          center = [
            "clock"
            "cat"
            "keyboard_layout"
          ];
          contact_shadow = true;
          end = [
            "media"
            "tray"
            "notifications"
            "clipboard"
            "control-center"
            "session"
          ];
          font_family = "JetBrains Mono ExtraBold";
          layer = "overlay";
          margin_ends = 100;
          padding = 15;
          radius = 40;
          reserve_space = false;
          shadow = false;
          start = [
            "launcher"
            "workspaces"
          ];
        };
      };

      desktop_widgets = {
        schema_version = 2;
        widget_order = [ ];
        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };
        widget = { };
      };

      dock = {
        active_scale = 0.95;
        auto_hide = true;
        background_opacity = 0.15;
        enabled = true;
        launcher_icon = "code";
        launcher_position = "start";
        magnification = false;
        position = "right";
        radius_bottom_left = 10;
        radius_bottom_right = 40;
        radius_top_left = 62;
        radius_top_right = 40;
        reserve_space = false;
        shadow = false;
        show_dots = true;
      };

      location = {
        address = "Tokyo, Japan";
      };

      lockscreen = {
        wallpaper = "/home/KangaZero/.config/multi-nix/assets/linux/cat-vibin.png";
      };

      lockscreen_widgets = {
        enabled = false;
        schema_version = 2;
        widget_order = [ "lockscreen-login-box@winit" ];
        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };
        widget."lockscreen-login-box@winit" = {
          box_height = 70.0;
          box_width = 400.0;
          cx = 960.0;
          cy = 1081.0;
          output = "winit";
          rotation = 0.0;
          type = "login_box";
          settings = {
            background_color = "surface_variant";
            background_opacity = 0.88;
            background_radius = 12.0;
            input_opacity = 1.0;
            input_radius = 6.0;
            show_login_button = true;
          };
        };
      };

      plugins = {
        enabled = [
          "noctalia/timer"
          "noctalia/bongocat"
        ];
      };

      shell = {
        font_family = "JetBrains Mono";
        niri_overview_type_to_launch_enabled = true;
        screen_time_enabled = true;
        settings_show_advanced = true;
        animation = {
          speed = 2.2;
        };
        panel = {
          floating_offset = 6;
          transparency_mode = "glass";
        };
        screen_corners = {
          enabled = true;
        };
      };

      theme = {
        builtin = "Noctalia";
        community_palette = "Catppuccin Lavender";
        mode = "dark";
        source = "community";
        wallpaper_scheme = "dysfunctional";
        templates = {
          builtin_ids = [
            "kitty"
            "niri"
          ];
          community_ids = [
            "neovim"
            "yazi"
          ];
        };
      };

      wallpaper = {
        directory = "/home/KangaZero/.config/multi-nix/assets/linux";
        edge_smoothness = 0.4;
        fill_mode = "fit";
        transition_duration = 2000;
        transition_on_startup = true;
        default = {
          path = "/home/KangaZero/.config/multi-nix/assets/linux/cat-vibin.png";
        };
        last = {
          path = "/home/KangaZero/.config/multi-nix/assets/linux/cat-vibin.png";
        };
        monitor.winit = {
          fill_color = "on_primary";
        };
        monitors.winit = {
          path = "/home/KangaZero/.config/multi-nix/assets/linux/cat-vibin.png";
        };
      };

      widget = {
        cat = {
          type = "noctalia/bongocat:cat";
        };
        launcher = {
          capsule = true;
          capsule_fill = "on_secondary";
          custom_image_colorize = true;
          glyph = "prong";
        };
      };
    };
  };

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  # noctalia launched by niri's `spawn-at-startup` (see wayland/niri/default.nix).
  # No systemd user service: weston bridge runs plain `niri` (not `niri --session`),
  # so graphical-session.target never fires and any unit bound to it stays dead.
}
