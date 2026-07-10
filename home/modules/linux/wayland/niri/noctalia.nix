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
        tint_intensity = 0.3;
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
            "audio_visualizer"
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
            "battery"
            "workspaces"
            "brightness"
          ];
        };
      };

      desktop_widgets = {
        schema_version = 2;
        widget_order = [
          "desktop-widget-0000000000000001"
          "desktop-widget-0000000000000002"
          "desktop-widget-0000000000000003"
          "desktop-widget-0000000000000004"
          "desktop-widget-0000000000000005"
        ];
        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };
        widget = {
          "desktop-widget-0000000000000001" = {
            box_height = 0.0;
            box_width = 0.0;
            cx = 274.0;
            cy = 687.0;
            output = "eDP-1";
            rotation = 0.0;
            type = "clock";
          };
          "desktop-widget-0000000000000002" = {
            box_height = 0.0;
            box_width = 0.0;
            cx = 284.0;
            cy = 162.0;
            output = "eDP-1";
            rotation = 0.0;
            type = "weather";
          };
          "desktop-widget-0000000000000003" = {
            box_height = 0.0;
            box_width = 0.0;
            cx = 1284.0;
            cy = 367.5;
            output = "eDP-1";
            rotation = 0.0;
            type = "sysmon";
            settings = {
              stat = "cpu_usage";
              stat2 = "cpu_temp";
            };
          };
          "desktop-widget-0000000000000004" = {
            box_height = 128.0;
            box_width = 272.0;
            cx = 616.0;
            cy = 672.0;
            output = "eDP-1";
            rotation = 0.0;
            type = "media_player";
          };
          "desktop-widget-0000000000000005" = {
            box_height = 0.0;
            box_width = 0.0;
            cx = 826.0;
            cy = 678.0;
            output = "eDP-1";
            rotation = 0.0;
            type = "fancy_audio_visualizer";
            settings = {
              background = false;
            };
          };
        };
      };

      idle = {
        behavior_order = [
          "lock"
          "screen-off"
          "lock-and-suspend"
        ];
        behavior = {
          lock = {
            action = "lock";
            enabled = true;
            timeout = 600.0;
          };
          "lock-and-suspend" = {
            action = "lock_and_suspend";
            enabled = false;
            timeout = 900.0;
          };
          "screen-off" = {
            action = "screen_off";
            enabled = true;
            timeout = 660.0;
          };
        };
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
        blurred_desktop = true;
        wallpaper = "/home/KangaZero/.config/multi-nix/assets/linux/cat-vibin.png";
      };

      lockscreen_widgets = {
        enabled = false;
        schema_version = 2;
        widget_order = [
          "lockscreen-login-box@eDP-1"
          "lockscreen-login-box@winit"
        ];
        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };
        widget."lockscreen-login-box@eDP-1" = {
          box_height = 70.0;
          box_width = 400.0;
          cx = 768.0;
          cy = 745.0;
          output = "eDP-1";
          rotation = 0.0;
          type = "login_box";
          settings = {
            background_color = "surface_variant";
            background_opacity = 0.88;
            background_radius = 12.0;
            input_opacity = 1.0;
            input_radius = 6.0;
            show_caps_lock = true;
            show_keyboard_layout = true;
            show_login_button = true;
            show_password_hint = true;
          };
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
            show_caps_lock = true;
            show_keyboard_layout = true;
            show_login_button = true;
            show_password_hint = true;
          };
        };
      };

      nightlight = {
        enabled = true;
      };

      plugins = {
        enabled = [
          "noctalia/timer"
          "noctalia/bongocat"
        ];
      };

      shell = {
        app_icon_colorize = true;
        password_style = "random";
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
        session = {
          actions = [
            {
              action = "lock";
              countdown_seconds = 0.0;
              enabled = true;
              shortcut = "1";
              variant = "default";
            }
            {
              action = "logout";
              countdown_seconds = 0.0;
              enabled = true;
              shortcut = "2";
              variant = "default";
            }
            {
              action = "lock_and_suspend";
              countdown_seconds = 0.0;
              enabled = true;
              shortcut = "3";
              variant = "default";
            }
            {
              action = "reboot";
              countdown_seconds = 0.0;
              enabled = true;
              shortcut = "4";
              variant = "default";
            }
            {
              action = "shutdown";
              countdown_seconds = 0.0;
              enabled = true;
              shortcut = "5";
              variant = "destructive";
            }
            {
              action = "command";
              command = "notify-send 'Noctalia' 'Custom session entry'";
              countdown_seconds = 0.0;
              enabled = false;
              variant = "default";
            }
          ];
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
        battery = {
          capsule = true;
        };
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
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  # noctalia launched by niri's `spawn-at-startup` (see wayland/niri/default.nix).
  # No systemd user service: weston bridge runs plain `niri` (not `niri --session`),
  # so graphical-session.target never fires and any unit bound to it stays dead.
}
