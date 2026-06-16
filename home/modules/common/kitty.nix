{ pkgs, assetsDir, ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrains Mono";
      package = pkgs.jetbrains-mono;
    };
    settings = {
      background = "#222436";
      foreground = "#c8d3f5";
      selection_background = "#2d3f76";
      selection_foreground = "#c8d3f5";
      url_color = "#4fd6be";
      cursor = "#bd93f9";
      cursor_text_color = "#222436";
      active_tab_background = "#82aaff";
      active_tab_foreground = "#1e2030";
      inactive_tab_background = "#2f334d";
      inactive_tab_foreground = "#545c7e";
      color0 = "#1b1d2b";
      color1 = "#ff757f";
      color2 = "#c3e88d";
      color3 = "#ffc777";
      color4 = "#82aaff";
      color5 = "#c099ff";
      color6 = "#86e1fc";
      color7 = "#828bb8";
      color8 = "#444a73";
      color9 = "#ff8d94";
      color10 = "#c7fb6d";
      color11 = "#ffd8ab";
      color12 = "#9ab8ff";
      color13 = "#caabff";
      color14 = "#b2ebff";
      color15 = "#c8d3f5";
      color16 = "#ff966c";
      color17 = "#c53b53";
      cursor_shape = "block";
      cursor_trail = 200;
      cursor_trail_decay = "0.1 0.4";
      cursor_trail_start_threshold = 2;
      mouse_hide_wait = -1;
      remember_window_size = true;
      initial_window_width = 1920;
      initial_window_height = 1080;
      window_border_width = "2pt";
      draw_minimal_borders = true;
      window_padding_width = 5;
      active_border_color = "#bd93f9";
      inactive_border_color = "#2a0944";
      inactive_text_alpha = "0.85";
      hide_window_decorations = true;
      tab_bar_style = "powerline";
      tab_powerline_style = "round";
      tab_bar_background = "none";
      tab_bar_margin_color = "none";
      background_opacity = "0.85";
      transparent_background_colors = "red@0.5 #00ff00@0.3";
      dynamic_background_opacity = true;
      allow_remote_control = "yes";
    };
  };
}
