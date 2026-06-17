{ pkgs, ... }:
{
  home.packages = [ pkgs.zellij ];

  xdg.configFile."zellij/layouts/default.kdl".text = ''
     layout {
        default_tab_template {
            children
            pane size=1 borderless=true {
                plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
                    format_left   "{mode} {tabs}"
                    format_center "{pipe_zjstatus_hints}"
                    format_right  "{session} {command_git_branch}"
                    format_space  ""

                    pipe_zjstatus_hints_format "#[bg=#cba6f7,fg=#1e1e2e,bold] {output} "
                    border_enabled  "true"
                    border_char     ""
                    border_format   "#[fg=#6c7086]{char}"
                    border_position "top"
                    hide_frame_for_single_pane "false"
                    mode_default_to_mode "locked"

                    mode_locked      "#[bg=#cba6f7,fg=#1e1e2e,bold]  錠  "
                    mode_normal      "#[bg=#f5c2e7,fg=#1e1e2e,bold]  定  "
                    mode_resize      "#[bg=#f38ba8,fg=#1e1e2e,bold]  整 󰊔"
                    mode_pane        "#[bg=#89b4fa,fg=#1e1e2e,bold]  枠  "
                    mode_move        "#[bg=#94e2d5,fg=#1e1e2e,bold]  移  "
                    mode_tab         "#[bg=#b4befe,fg=#1e1e2e,bold]  頁 󰓩 "
                    mode_scroll      "#[bg=#cdd6f4,fg=#1e1e2e,bold]  捲 󱕒 "
                    mode_search      "#[bg=#f9e2af,fg=#1e1e2e,bold]  索  "
                    mode_entersearch "#[bg=#f9e2af,fg=#1e1e2e,bold]  尋  "
                    mode_renametab   "#[bg=#cba6f7,fg=#1e1e2e,bold]  頁名  "
                    mode_renamepane  "#[bg=#cba6f7,fg=#1e1e2e,bold]  枠名  "
                    mode_session     "#[bg=#f38ba8,fg=#1e1e2e,bold]  期  "
                    mode_tmux        "#[bg=#cdd6f4,fg=#1e1e2e,bold]  端 󰆍 "

                    tab_active              "#[bg=#cba6f7,fg=#1e1e2e,bold] {index} {name} "
                    tab_active_fullscreen   "#[bg=#cba6f7,fg=#1e1e2e,bold] {fullscreen_indicator} {index} {name} "
                    tab_active_sync         "#[bg=#cba6f7,fg=#1e1e2e,bold] {sync_indicator} {index} {name} "
                    tab_normal              "#[fg=#6c7086,bold] {index} {name} "
                    tab_normal_fullscreen   "#[fg=#6c7086,bold] {fullscreen_indicator} {index} {name} "
                    tab_normal_sync         "#[fg=#6c7086,bold] {sync_indicator} {index} {name} "
                    tab_separator " "
                    tab_sync_indicator       "󰓦"
                    tab_fullscreen_indicator "󰊓"
                    tab_floating_indicator   "⬚"
                    tab_rename              "#[bg=#b4befe,fg=#1e1e2e,bold] {index} {name} {floating_indicator} #[bg=#1e1e2e,fg=#cba6f7,bold]"
                    tab_display_count         "9"
                    tab_truncate_start_format "#[fg=#f9e2af]  +{count}  "
                    tab_truncate_end_format   "#[fg=#f9e2af]   +{count} "

                    command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                    command_git_branch_format      "#[bg=#1e1e2e,fg=#cba6f7,bold]#[bg=#f38ba8,fg=#1e1e2e,bold]  {stdout} "
                    command_git_branch_interval    "10"
                    command_git_branch_rendermode  "static"
                }
            }
        }
    }
  '';
}
