_:
let
  colorFocusActive = "#8897F4";
  colorFocusInactive = "#2f354b";
  colorBorderActive = "#c099ff";
  colorBorderInactive = "#c8d3f5";
in
{
  imports = [
    ./noctalia.nix
  ];

  xdg.configFile."niri/config.kdl".text = ''
                                                // ─── Input ───────────────────────────────────────────────────────────────
                                                input {
                                                    keyboard {
                                                        xkb {
                                                            layout "us,jp"
                                                        }
                                                    }

                                                    touchpad {
                                                        tap
                                                        natural-scroll
                                                    }
                                                }

                                                // ─── Layout ──────────────────────────────────────────────────────────────
                                                layout {
                                                    always-center-single-column
                                                    gaps 8

                                                    focus-ring {
                                            	    on
                                                        width 2
                                                        active-color "${colorFocusActive}"
                                                        inactive-color "${colorFocusInactive}"
                                                    }
                                            	border {
                                                       on
                                        	       width 3
                                            	   active-color "${colorBorderActive}"
                                        	   inactive-color "${colorBorderInactive}"
                                        		}
                                                }

                                                // ─── Layer ──────────────────────────────────────────────────────────────
                                		// For v4 use : match namespace="noctalia-overview"
                                    	    layer-rule {
                                                 match namespace="^noctalia-backdrop"
                                    		 place-within-backdrop true
                                    	    }

                                                // ─── Gestures ──────────────────────────────────────────────────────────────
                                        	gestures {
                                        	}

                                                // ─── Animations ──────────────────────────────────────────────────────────────
                                                animations {

                                                workspace-switch {
                                                    spring damping-ratio=1.0 stiffness=1500 epsilon=0.001
                                                }

                                                window-open {
                                                    duration-ms 100
                                                    curve "ease-out-expo"
                                                }

                                                window-close {
                                                    duration-ms 100
                                                    curve "ease-out-quad"
                                                }

                                                horizontal-view-movement {
                                                    spring damping-ratio=1.0 stiffness=1200 epsilon=0.001
                                                }

                                                window-movement {
                                                    spring damping-ratio=1.0 stiffness=1200 epsilon=0.001
                                                }

                                                window-resize {
                                                    spring damping-ratio=1.0 stiffness=1200 epsilon=0.001
                                                }

                                                config-notification-open-close {
                                                    spring damping-ratio=0.6 stiffness=1200 epsilon=0.001
                                                }

                                                exit-confirmation-open-close {
                                                    spring damping-ratio=0.6 stiffness=700 epsilon=0.01
                                                }

                                                screenshot-ui-open {
                                                    duration-ms 120
                                                    curve "ease-out-quad"
                                                }

                                                overview-open-close {
                                                    spring damping-ratio=1.0 stiffness=1200 epsilon=0.001
                                                }

                                                recent-windows-close {
                                                    spring damping-ratio=1.0 stiffness=1200 epsilon=0.001
                                                }
                                            }

                                                prefer-no-csd

                                                // ─── Autostart ───────────────────────────────────────────────────────────
                                                // Launched via `weston --fullscreen -- niri` (not niri-session), so
                                                // graphical-session.target never fires. Spawn services directly.
                                                spawn-at-startup "noctalia"

                                                // ─── Keybinds ────────────────────────────────────────────────────────────
                                                // Mod = Alt.  Super is captured by Windows/WSLg window chrome.
                            		    // Current noctalia Keybinds as for v5 : https://docs.noctalia.dev/v5/ipc/shell-and-ui/
                                                binds {
                                                    // ── Launchers ──────────────────────────────────────────────────────
                                                    Alt+Return { spawn "kitty"; }
                                                    Alt+Shift+Return { spawn "firefox-devedition"; }
                				    Alt+Space       { spawn "noctalia" "msg" "panel-toggle" "launcher"; }
                                                    Alt+N           { spawn "kitty" "--title" "nix-search-tv" "-e" "ns"; }
        					    Alt+Shift+Comma { spawn "noctalia" "msg" "settings-toggle"; }
                                                    Alt+Shift+O     { toggle-overview; }
                                                    Alt+Shift+V     { spawn "noctalia" "msg" "panel-toggle" "clipboard"; }
                                                    Alt+Shift+E     { spawn "noctalia" "msg" "panel-toggle" "session"; }
                                                    Alt+Shift+W     { spawn "noctalia" "msg" "panel-toggle" "wallpaper"; }
                                                    Alt+Shift+I     { spawn "noctalia" "msg" "panel-toggle" "control-center"; }
    						Alt+Shift+S     { spawn "sh" "-c" "notify-send 'Noctalia Status' \"$(noctalia msg status | jq -r 'to_entries[] | \"\\(.key): \\(.value)\"')\""; }
                                                    Shift+Space     { show-hotkey-overlay; }

                                                    // ── Screenshots ────────────────────────────────────────────────────
                                                    Print { spawn "noctalia" "msg" "screenshot-fullscreen"; }
                                                    Alt+Print { spawn "noctalia" "msg" "screenshot-region"; }
                                                    Alt+Shift+Print { spawn "noctalia" "msg" "screenshot-fullscreen" "all"; }

                                                    // ── Window management ──────────────────────────────────────────────
                                                    Alt+Shift+Q repeat=false { close-window; }
                                                    Alt+F               { fullscreen-window; }
                                                    Alt+Shift+F         { maximize-column; }
                                                    Alt+T           { toggle-window-floating; }
                                                    Alt+Shift+T repeat=false { switch-focus-between-floating-and-tiling; }
                                                    Alt+Shift+C         { center-column; }
                                                    Alt+Comma           { consume-or-expel-window-left; }
                                                    Alt+Period          { consume-or-expel-window-right; }

                                                    // ── Focus — vim keys ──────────────────────────────────────────────
                                                    Alt+H { focus-column-left; }
                                                    Alt+J { focus-window-down; }
                                                    Alt+K { focus-window-up; }
                                                    Alt+L { focus-column-right; }

                                                    // ── Focus — arrow keys ────────────────────────────────────────────
                                                    Alt+Left  { focus-column-left; }
                                                    Alt+Down  { focus-window-down; }
                                                    Alt+Up    { focus-window-up; }
                                                    Alt+Right { focus-column-right; }

                                                    // ── Move — vim keys ───────────────────────────────────────────────
                                                    Alt+Shift+H { move-column-left; }
                                                    Alt+Shift+J { move-window-down; }
                                                    Alt+Shift+K { move-window-up; }
                                                    Alt+Shift+L { move-column-right; }

                                                    // ── Move — arrow keys ─────────────────────────────────────────────
                                                    Alt+Shift+Left  { move-column-left; }
                                                    Alt+Shift+Down  { move-window-down; }
                                                    Alt+Shift+Up    { move-window-up; }
                                                    Alt+Shift+Right { move-column-right; }

                                                    // ── Workspaces ────────────────────────────────────────────────────
                                                    Alt+1 { focus-workspace 1; }
                                                    Alt+2 { focus-workspace 2; }
                                                    Alt+3 { focus-workspace 3; }
                                                    Alt+4 { focus-workspace 4; }
                                                    Alt+5 { focus-workspace 5; }
                                                    Alt+6 { focus-workspace 6; }
                                                    Alt+7 { focus-workspace 7; }
                                                    Alt+8 { focus-workspace 8; }
                                                    Alt+9 { focus-workspace 9; }

                                                    Alt+Shift+1 { move-column-to-workspace 1; }
                                                    Alt+Shift+2 { move-column-to-workspace 2; }
                                                    Alt+Shift+3 { move-column-to-workspace 3; }
                                                    Alt+Shift+4 { move-column-to-workspace 4; }
                                                    Alt+Shift+5 { move-column-to-workspace 5; }
                                                    Alt+Shift+6 { move-column-to-workspace 6; }
                                                    Alt+Shift+7 { move-column-to-workspace 7; }
                                                    Alt+Shift+8 { move-column-to-workspace 8; }
                                                    Alt+Shift+9 { move-column-to-workspace 9; }

                                                    // ── Workspace scroll ──────────────────────────────────────────────
                                                    Alt+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
                                                    Alt+WheelScrollUp   cooldown-ms=150 { focus-workspace-up; }

                                                    // ── Resize ────────────────────────────────────────────────────────
                                                    Alt+R       { switch-preset-column-width; }
                                                    Alt+Minus   { set-column-width "-10%"; }
                                                    Alt+Equal   { set-column-width "+10%"; }
                                                    Alt+Shift+Minus { set-window-height "-10%"; }
                                                    Alt+Shift+Equal { set-window-height "+10%"; }

                                                    // ── Keyboard layout toggle ─────────────────────────────────────────
                                                    Alt+Ctrl+L { switch-layout "next"; }
                                                }

                                                // ─── Window rules ────────────────────────────────────────────────────────
                                                window-rule {
                                                    match title="nix-search-tv"
                                                    open-floating true
                                                    default-column-width { proportion 0.75; }
                                                    default-window-height { proportion 0.75; }
                                                }
                                		// For v5 : taken from : https://docs.noctalia.dev/v5/compositor-settings/niri/ 
                                		window-rule {
                                			// Rounded corners for a modern look.
                                			geometry-corner-radius 20

                                				// Clips window contents to the rounded corner boundaries.
                                				clip-to-geometry true
                                		}

                                		// Floating Noctalia settings window.
                                		window-rule {
                                			match app-id="dev.noctalia.Noctalia.Settings"
                                				open-floating true
                                				default-column-width { fixed 1080; }
                                			default-window-height { fixed 920; }
                                		}

                                		debug {
                                			// Allows notification actions and window activation from Noctalia.
                                			honor-xdg-activation-with-invalid-serial
                                		}
  '';
}
