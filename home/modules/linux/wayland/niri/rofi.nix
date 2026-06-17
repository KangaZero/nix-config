{ pkgs, ... }:
let
  palette = ''
    * {
        background:     #1e1e2eff;
        background-alt: #313244ff;
        foreground:     #cdd6f4ff;
        selected:       #cba6f7ff;
        active:         #a6e3a1ff;
        urgent:         #f38ba8ff;
        font:           "JetBrainsMono Nerd Font 10";
    }
  '';

  # NOTE: pkgs.rofi-wayland was merged into pkgs.rofi on nixpkgs-unstable
  # (alias added 2025-09-06). pkgs.rofi now ships both X11 and Wayland
  # backends. display-wayland = true in config.rasi selects Wayland at
  # runtime — no separate package needed.
  rofiPkg = pkgs.rofi.override { plugins = [ pkgs.rofi-calc ]; };

  # WSL note: systemctl poweroff/reboot act on the WSL distro's systemd.
  rofi-powermenu = pkgs.writeShellApplication {
    name = "rofi-powermenu";
    runtimeInputs = [
      rofiPkg
      pkgs.niri
    ];
    text = ''
      chosen=$(printf '%s\n' "  Exit Niri" \
        | rofi -dmenu -i -theme "$HOME/.config/rofi/powermenu.rasi" -p "")
      case "$chosen" in
        *"Exit Niri") niri msg action quit ;;
      esac
    '';
  };

  rofi-clipboard = pkgs.writeShellApplication {
    name = "rofi-clipboard";
    runtimeInputs = [
      rofiPkg
      pkgs.cliphist
      pkgs.wl-clipboard
    ];
    text = ''
      cliphist list \
        | rofi -dmenu \
            -theme "$HOME/.config/rofi/applet.rasi" \
            -theme-str 'listview { lines: 10; } window { width: 700px; }' \
        | cliphist decode \
        | wl-copy
    '';
  };

  rofi-cheatsheet = pkgs.writeShellApplication {
    name = "rofi-cheatsheet";
    runtimeInputs = [ rofiPkg ];
    text = ''
      cat <<'EOF' | rofi -dmenu -i -markup-rows -p "Keys" \
        -theme "$HOME/.config/rofi/applet.rasi" \
        -theme-str 'listview { lines: 18; scrollbar: true; } window { width: 680px; } scrollbar { handle-width: 4px; }' \
        >/dev/null || true
      <b>──────────  niri  (mod = Alt)  ──────────</b>
      <span foreground='#cba6f7'>$mod+Return</span>        terminal (kitty)
      <span foreground='#cba6f7'>$mod+d</span>             app launcher (rofi)
      <span foreground='#cba6f7'>$mod+Tab</span>           window switcher
      <span foreground='#cba6f7'>$mod+Shift+d</span>       combi (apps+run+windows)
      <span foreground='#cba6f7'>$mod+c</span>             calculator
      <span foreground='#cba6f7'>$mod+Shift+v</span>       clipboard history
      <span foreground='#cba6f7'>$mod+Shift+e</span>       power menu
      <span foreground='#cba6f7'>$mod+Shift+slash</span>   this cheatsheet
      <span foreground='#cba6f7'>$mod+Shift+q</span>       kill window
      <b>── focus / move ──</b>
      <span foreground='#89b4fa'>$mod+h/j/k/l</span>       focus left/down/up/right
      <span foreground='#89b4fa'>$mod+Arrows</span>        focus (arrow keys)
      <span foreground='#89b4fa'>$mod+Shift+h/j/k/l</span> move window
      <b>── layout ──</b>
      <span foreground='#a6e3a1'>$mod+F</span>             fullscreen
      <span foreground='#a6e3a1'>$mod+Shift+F</span>       maximize column
      <span foreground='#a6e3a1'>$mod+Space</span>         float toggle
      <span foreground='#a6e3a1'>$mod+R</span>             cycle preset column widths
      <span foreground='#a6e3a1'>$mod+Minus</span>         shrink column
      <span foreground='#a6e3a1'>$mod+Equal</span>         expand column
      <b>── workspaces ──</b>
      <span foreground='#fab387'>$mod+1..9</span>          switch workspace
      <span foreground='#fab387'>$mod+Shift+1..9</span>    move window to workspace
      <b>──────────  rofi  ──────────</b>
      <span foreground='#cba6f7'>Enter / Esc</span>        select / cancel
      <span foreground='#cba6f7'>Shift+Left/Right</span>   switch mode (Apps/Run/Files/Win)
      <span foreground='#cba6f7'>Ctrl+Tab</span>           next mode
      EOF
    '';
  };
in
{
  home.packages = [
    rofiPkg
    rofi-powermenu
    rofi-clipboard
    rofi-cheatsheet
  ];

  xdg.configFile = {
    "rofi/config.rasi".text = ''
      configuration {
          modi:                       "drun,run,filebrowser,window,combi";
          combi-modi:                 "drun,run,window";
          case-sensitive:             false;
          cycle:                      true;
          show-icons:                 true;
          terminal:                   "kitty";
          drun-display-format:        "{name} [<span weight='light' size='small'><i>({generic})</i></span>]";
          window-format:              "{w} · {c} · {t:0}";
          display-drun:               " Apps";
          display-run:                " Run";
          display-filebrowser:        " Files";
          display-window:             " Windows";
          font:                       "JetBrainsMono Nerd Font 11";

          kb-row-up:           "Up,Control+k";
          kb-row-down:         "Down,Control+j";
          kb-row-left:         "Control+Page_Up,Control+h";
          kb-row-right:        "Control+Page_Down,Control+l";
          kb-accept-entry:     "Control+m,Return,KP_Enter";
          kb-remove-to-eol:    "";
          kb-remove-char-back: "BackSpace,Shift+BackSpace";
          kb-mode-complete:    "";
      }

      @theme "~/.config/rofi/launcher.rasi"
    '';

    "rofi/launcher.rasi".text = ''
      ${palette}
      * {
          border-colour:               var(selected);
          handle-colour:               var(selected);
          background-colour:           var(background);
          foreground-colour:           var(foreground);
          alternate-background:        var(background-alt);
          normal-background:           var(background);
          normal-foreground:           var(foreground);
          urgent-background:           var(urgent);
          urgent-foreground:           var(background);
          active-background:           var(active);
          active-foreground:           var(background);
          selected-normal-background:  var(selected);
          selected-normal-foreground:  var(background);
          selected-urgent-background:  var(active);
          selected-urgent-foreground:  var(background);
          selected-active-background:  var(urgent);
          selected-active-foreground:  var(background);
          alternate-normal-background: var(background);
          alternate-normal-foreground: var(foreground);
          alternate-urgent-background: var(urgent);
          alternate-urgent-foreground: var(background);
          alternate-active-background: var(active);
          alternate-active-foreground: var(background);
      }

      window {
          transparency:                "real";
          location:                    center;
          anchor:                      center;
          fullscreen:                  false;
          width:                       800px;
          x-offset:                    0px;
          y-offset:                    0px;
          enabled:                     true;
          margin:                      0px;
          padding:                     0px;
          border:                      0px solid;
          border-radius:               20px;
          border-color:                @border-colour;
          cursor:                      "default";
          background-color:            @background-colour;
      }

      mainbox {
          enabled:                     true;
          spacing:                     10px;
          margin:                      0px;
          padding:                     40px;
          border:                      0px solid;
          border-radius:               0px 0px 0px 0px;
          border-color:                @border-colour;
          background-color:            transparent;
          children:                    [ "inputbar", "message", "listview", "mode-switcher" ];
      }

      inputbar {
          enabled:                     true;
          spacing:                     10px;
          margin:                      0px;
          padding:                     0px;
          border:                      0px solid;
          border-radius:               0px;
          border-color:                @border-colour;
          background-color:            transparent;
          text-color:                  @foreground-colour;
          children:                    [ "prompt", "textbox-prompt-colon", "entry" ];
      }

      prompt {
          enabled:                     true;
          background-color:            inherit;
          text-color:                  inherit;
      }
      textbox-prompt-colon {
          enabled:                     true;
          expand:                      false;
          str:                         "::";
          background-color:            inherit;
          text-color:                  inherit;
      }
      entry {
          enabled:                     true;
          background-color:            inherit;
          text-color:                  inherit;
          cursor:                      text;
          placeholder:                 "Search...";
          placeholder-color:           inherit;
      }
      num-filtered-rows {
          enabled:                     true;
          expand:                      false;
          background-color:            inherit;
          text-color:                  inherit;
      }
      textbox-num-sep {
          enabled:                     true;
          expand:                      false;
          str:                         "/";
          background-color:            inherit;
          text-color:                  inherit;
      }
      num-rows {
          enabled:                     true;
          expand:                      false;
          background-color:            inherit;
          text-color:                  inherit;
      }
      case-indicator {
          enabled:                     true;
          background-color:            inherit;
          text-color:                  inherit;
      }

      listview {
          enabled:                     true;
          columns:                     2;
          lines:                       10;
          cycle:                       true;
          dynamic:                     true;
          scrollbar:                   true;
          layout:                      vertical;
          reverse:                     false;
          fixed-height:                true;
          fixed-columns:               true;
          spacing:                     5px;
          margin:                      0px;
          padding:                     0px;
          border:                      0px solid;
          border-radius:               0px;
          border-color:                @border-colour;
          background-color:            transparent;
          text-color:                  @foreground-colour;
          cursor:                      "default";
      }
      scrollbar {
          handle-width:                10px ;
          handle-color:                @handle-colour;
          border-radius:               10px;
          background-color:            @alternate-background;
      }

      element {
          enabled:                     true;
          spacing:                     10px;
          margin:                      0px;
          padding:                     5px 10px;
          border:                      0px solid;
          border-radius:               20px;
          border-color:                @border-colour;
          background-color:            transparent;
          text-color:                  @foreground-colour;
          cursor:                      pointer;
      }
      element normal.normal {
          background-color:            var(normal-background);
          text-color:                  var(normal-foreground);
      }
      element normal.urgent {
          background-color:            var(urgent-background);
          text-color:                  var(urgent-foreground);
      }
      element normal.active {
          background-color:            var(active-background);
          text-color:                  var(active-foreground);
      }
      element selected.normal {
          background-color:            var(selected-normal-background);
          text-color:                  var(selected-normal-foreground);
      }
      element selected.urgent {
          background-color:            var(selected-urgent-background);
          text-color:                  var(selected-urgent-foreground);
      }
      element selected.active {
          background-color:            var(selected-active-background);
          text-color:                  var(selected-active-foreground);
      }
      element alternate.normal {
          background-color:            var(alternate-normal-background);
          text-color:                  var(alternate-normal-foreground);
      }
      element alternate.urgent {
          background-color:            var(alternate-urgent-background);
          text-color:                  var(alternate-urgent-foreground);
      }
      element alternate.active {
          background-color:            var(alternate-active-background);
          text-color:                  var(alternate-active-foreground);
      }
      element-icon {
          background-color:            transparent;
          text-color:                  inherit;
          size:                        24px;
          cursor:                      inherit;
      }
      element-text {
          background-color:            transparent;
          text-color:                  inherit;
          highlight:                   inherit;
          cursor:                      inherit;
          vertical-align:              0.5;
          horizontal-align:            0.0;
      }

      mode-switcher{
          enabled:                     true;
          spacing:                     10px;
          margin:                      0px;
          padding:                     0px;
          border:                      0px solid;
          border-radius:               0px;
          border-color:                @border-colour;
          background-color:            transparent;
          text-color:                  @foreground-colour;
      }
      button {
          padding:                     5px 10px;
          border:                      0px solid;
          border-radius:               20px;
          border-color:                @border-colour;
          background-color:            @alternate-background;
          text-color:                  inherit;
          cursor:                      pointer;
      }
      button selected {
          background-color:            var(selected-normal-background);
          text-color:                  var(selected-normal-foreground);
      }

      message {
          enabled:                     true;
          margin:                      0px;
          padding:                     0px;
          border:                      0px solid;
          border-radius:               0px 0px 0px 0px;
          border-color:                @border-colour;
          background-color:            transparent;
          text-color:                  @foreground-colour;
      }
      textbox {
          padding:                     5px 10px;
          border:                      0px solid;
          border-radius:               20px;
          border-color:                @border-colour;
          background-color:            @alternate-background;
          text-color:                  @foreground-colour;
          vertical-align:              0.5;
          horizontal-align:            0.0;
          highlight:                   none;
          placeholder-color:           @foreground-colour;
          blink:                       true;
          markup:                      true;
      }
      error-message {
          padding:                     10px;
          border:                      2px solid;
          border-radius:               20px;
          border-color:                @border-colour;
          background-color:            @background-colour;
          text-color:                  @foreground-colour;
      }
    '';

    "rofi/powermenu.rasi".text = ''
      configuration {
          show-icons:                 false;
      }

      ${palette}

      window {
          transparency:                "real";
          location:                    center;
          anchor:                      center;
          fullscreen:                  false;
          width:                       400px;
          x-offset:                    0px;
          y-offset:                    0px;
          enabled:                     true;
          margin:                      0px;
          padding:                     0px;
          border:                      0px solid;
          border-radius:               12px;
          border-color:                @selected;
          cursor:                      "default";
          background-color:            @background;
      }

      mainbox {
          enabled:                     true;
          spacing:                     10px;
          margin:                      0px;
          padding:                     20px;
          border:                      0px solid;
          border-radius:               0px;
          border-color:                @selected;
          background-color:            transparent;
          children:                    [ "inputbar", "message", "listview" ];
      }

      inputbar {
          enabled:                     true;
          spacing:                     10px;
          margin:                      0px;
          padding:                     0px;
          border:                      0px;
          border-radius:               0px;
          border-color:                @selected;
          background-color:            transparent;
          text-color:                  @foreground;
          children:                    [ "textbox-prompt-colon", "prompt"];
      }

      textbox-prompt-colon {
          enabled:                     true;
          expand:                      false;
          str:                         "";
          padding:                     10px 14px;
          border-radius:               10px;
          background-color:            @urgent;
          text-color:                  @background;
      }
      prompt {
          enabled:                     true;
          padding:                     10px;
          border-radius:               10px;
          background-color:            @active;
          text-color:                  @background;
      }

      message {
          enabled:                     true;
          margin:                      0px;
          padding:                     10px;
          border:                      0px solid;
          border-radius:               10px;
          border-color:                @selected;
          background-color:            @background-alt;
          text-color:                  @foreground;
      }
      textbox {
          background-color:            inherit;
          text-color:                  inherit;
          vertical-align:              0.5;
          horizontal-align:            0.0;
          placeholder-color:           @foreground;
          blink:                       true;
          markup:                      true;
      }
      error-message {
          padding:                     10px;
          border:                      0px solid;
          border-radius:               0px;
          border-color:                @selected;
          background-color:            @background;
          text-color:                  @foreground;
      }

      listview {
          enabled:                     true;
          columns:                     1;
          lines:                       3;
          cycle:                       true;
          dynamic:                     true;
          scrollbar:                   false;
          layout:                      vertical;
          reverse:                     false;
          fixed-height:                true;
          fixed-columns:               true;
          spacing:                     5px;
          margin:                      0px;
          padding:                     0px;
          border:                      0px solid;
          border-radius:               0px;
          border-color:                @selected;
          background-color:            transparent;
          text-color:                  @foreground;
          cursor:                      "default";
      }

      element {
          enabled:                     true;
          spacing:                     0px;
          margin:                      0px;
          padding:                     10px;
          border:                      0px solid;
          border-radius:               10px;
          border-color:                @selected;
          background-color:            transparent;
          text-color:                  @foreground;
          cursor:                      pointer;
      }
      element-text {
          background-color:            transparent;
          text-color:                  inherit;
          cursor:                      inherit;
          vertical-align:              0.5;
          horizontal-align:            0.0;
      }
      element selected.normal {
          background-color:            var(selected);
          text-color:                  var(background);
      }
    '';

    "rofi/applet.rasi".text = ''
      configuration {
          show-icons:                 false;
      }

      ${palette}

      window {
          transparency:                "real";
          location:                    center;
          anchor:                      center;
          fullscreen:                  false;
          width:                       400px;
          x-offset:                    0px;
          y-offset:                    0px;
          margin:                      0px;
          padding:                     0px;
          border:                      1px solid;
          border-radius:               0px;
          border-color:                @selected;
          cursor:                      "default";
          background-color:            @background;
      }

      mainbox {
          enabled:                     true;
          spacing:                     10px;
          margin:                      0px;
          padding:                     20px;
          background-color:            transparent;
          children:                    [ "inputbar", "message", "listview" ];
      }

      inputbar {
          enabled:                     true;
          spacing:                     10px;
          padding:                     0px;
          border:                      0px;
          border-radius:               0px;
          border-color:                @selected;
          background-color:            transparent;
          text-color:                  @foreground;
          children:                    [ "textbox-prompt-colon", "prompt"];
      }

      textbox-prompt-colon {
          enabled:                     true;
          expand:                      false;
          str:                         "";
          padding:                     10px 13px;
          border-radius:               0px;
          background-color:            @urgent;
          text-color:                  @background;
      }
      prompt {
          enabled:                     true;
          padding:                     10px;
          border-radius:               0px;
          background-color:            @active;
          text-color:                  @background;
      }

      message {
          enabled:                     true;
          margin:                      0px;
          padding:                     10px;
          border:                      0px solid;
          border-radius:               0px;
          border-color:                @selected;
          background-color:            @background-alt;
          text-color:                  @foreground;
      }
      textbox {
          background-color:            inherit;
          text-color:                  inherit;
          vertical-align:              0.5;
          horizontal-align:            0.0;
      }

      listview {
          enabled:                     true;
          columns:                     1;
          lines:                       6;
          cycle:                       true;
          scrollbar:                   false;
          layout:                      vertical;
          spacing:                     5px;
          background-color:            transparent;
          cursor:                      "default";
      }

      element {
          enabled:                     true;
          padding:                     10px;
          border:                      0px solid;
          border-radius:               0px;
          border-color:                @selected;
          background-color:            transparent;
          text-color:                  @foreground;
          cursor:                      pointer;
      }
      element-text {
          background-color:            transparent;
          text-color:                  inherit;
          cursor:                      inherit;
          vertical-align:              0.5;
          horizontal-align:            0.0;
      }
      element normal.normal,
      element alternate.normal {
          background-color:            var(background);
          text-color:                  var(foreground);
      }
      element normal.urgent,
      element alternate.urgent,
      element selected.active {
          background-color:            var(urgent);
          text-color:                  var(background);
      }
      element normal.active,
      element alternate.active,
      element selected.urgent {
          background-color:            var(active);
          text-color:                  var(background);
      }
      element selected.normal {
          background-color:            var(selected);
          text-color:                  var(background);
      }
    '';
  };
}
