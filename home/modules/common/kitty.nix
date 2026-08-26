{ pkgs, ... }:
let
  c = import ./theme.nix;
in
{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrains Mono";
      package = pkgs.jetbrains-mono;
    };
    settings = {
      # ── palette ────────────────────────────────────────────────────────
      background = c.bgTerminal;
      foreground = c.fg;
      selection_background = c.bgHighlight;
      selection_foreground = c.fg;
      url_color = c.teal;
      cursor = c.purple;
      cursor_text_color = c.bgTerminal;

      # ── tabs ───────────────────────────────────────────────────────────
      active_tab_background = c.blue;
      active_tab_foreground = c.bg;
      inactive_tab_background = "#2f334d"; # mid-dark, not a named palette slot
      inactive_tab_foreground = c.dim;

      # ── borders ────────────────────────────────────────────────────────
      active_border_color = c.purple;
      inactive_border_color = "#2a0944"; # deep purple shadow, intentionally off-palette
      inactive_text_alpha = "0.85";

      # ── ANSI 16-color palette ───────────────────────────────────────────
      # Terminal-emulator specific; not semantic — kept hardcoded.
      color0 = "#1b1d2b"; # black
      color1 = c.red; # red
      color2 = c.green; # green
      color3 = c.yellow; # yellow
      color4 = c.blue; # blue
      color5 = "#c099ff"; # magenta (standard TN moon purple, not kanga accent)
      color6 = c.cyan; # cyan
      color7 = c.muted; # white
      color8 = "#444a73"; # bright black
      color9 = "#ff8d94"; # bright red
      color10 = "#c7fb6d"; # bright green
      color11 = "#ffd8ab"; # bright yellow
      color12 = "#9ab8ff"; # bright blue
      color13 = "#caabff"; # bright magenta
      color14 = "#b2ebff"; # bright cyan
      color15 = c.fg; # bright white
      color16 = c.orange; # extended orange
      color17 = "#c53b53"; # extended dark red

      # ── cursor ─────────────────────────────────────────────────────────
      cursor_shape = "block";
      cursor_trail = 200;
      cursor_trail_decay = "0.1 0.4";
      cursor_trail_start_threshold = 2;

      # ── window ─────────────────────────────────────────────────────────
      mouse_hide_wait = -1;
      remember_window_size = true;
      initial_window_width = 1920;
      initial_window_height = 1080;
      window_border_width = "2pt";
      draw_minimal_borders = true;
      window_padding_width = 5;
      hide_window_decorations = true;

      # ── tab bar ────────────────────────────────────────────────────────
      tab_bar_style = "powerline";
      tab_powerline_style = "round";
      tab_bar_background = "none";
      tab_bar_margin_color = "none";

      # ── background ─────────────────────────────────────────────────────
      background_opacity = "0.85";
      transparent_background_colors = "red@0.5 #00ff00@0.3";
      dynamic_background_opacity = true;
      allow_remote_control = "yes";
    };
  };
}
