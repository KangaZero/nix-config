_: {
  programs.zsh = {
    autosuggestion.highlight = "fg=#ac62de,bg=#134d4d,bold,underline";

    initContent = ''
      weston() {
        # WSLg creates /tmp/.X11-unix without the sticky bit, breaking
        # xwayland-satellite's socket creation. Fix it before launching.
        sudo chmod 1777 /tmp/.X11-unix 2>/dev/null || true
        # Explicit cursor vars ensure weston and niri both use the same theme,
        # preventing the double-cursor artifact in nested compositor mode.
        XCURSOR_THEME=Bibata-Modern-Classic XCURSOR_SIZE=24 command weston --fullscreen -- niri
      }
      nix-gc() {
        nix-collect-garbage --delete-older-than "$1" && nix store gc;
      }
      kill-port() {
        local port="$1"
        [ -z "$port" ] && { echo "usage: kill-port <port>" >&2; return 1; }
        local lpids
        lpids=$(ss -ltnp "sport = :$port" 2>/dev/null | grep -oP 'pid=\K[0-9]+' | sort -u)
        [ -z "$lpids" ] && { echo "kill-port: nothing listening on :$port" >&2; return 1; }
        local targets="" pid ppid
        for pid in $lpids; do
          targets="$targets $pid"
          ppid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
          [ -n "$ppid" ] && [ "$ppid" -gt 1 ] && [ "$ppid" != "$$" ] && targets="$targets $ppid"
        done
        targets=$(echo "$targets" | tr ' ' '\n' | grep -v '^$' | sort -u)
        echo "kill-port: killing $(echo $targets | tr '\n' ' ')on :$port" >&2
        echo "$targets" | xargs -r kill -9
      }
    '';

    shellAliases = {
      nixRebuildStatus = "systemctl --no-pager status nixos-rebuild-switch-to-configuration.service 2>/dev/null; pgrep -af 'nixos-rebuild|switch-to-configuration' || echo 'no rebuild running'";
      nixRebuildKill = "sudo systemctl stop nixos-rebuild-switch-to-configuration.service 2>/dev/null; sudo systemctl reset-failed nixos-rebuild-switch-to-configuration.service 2>/dev/null; echo 'cleared stale activation unit'";
      ez = "eza -laF --icons=always --group-directories-first --git-repos-no-status --octal-permissions --modified --numeric";
      cheatsheet-az = ''
        cat <<'EOF' | bat --language=md --style=plain
        # Azure DevOps CLI cheatsheet

        ## One-time setup
        az devops configure --defaults \
          organization=https://dev.azure.com/<org> \
          project=<project>

        ## PR — create
        az repos pr create \
          --repository <repo> \
          --source-branch <branch> \
          --target-branch main \
          --title "feat: my change" \
          --description "## Summary"

        ## PR — list active
        az repos pr list --repository <repo> --status active

        ## PR — show
        az repos pr show --id <id>

        ## PR — abandon
        az repos pr update --id <id> --status abandoned

        ## PR — approve
        az repos pr set-vote --id <id> --vote approve

        ## PR — reactivate
        az repos pr update --id <id> --status active

        ## Comments (REST only — az repos pr has no threads command)
        TOKEN=$(az account get-access-token \
          --resource 499b84ac-1321-427f-aa17-267ca6975798 \
          --query accessToken -o tsv)

        ## Git push via az token (no PAT needed)
        TOKEN=$(az account get-access-token \
          --resource 499b84ac-1321-427f-aa17-267ca6975798 \
          --query accessToken -o tsv)
        git -c http.extraHeader="Authorization: Bearer $TOKEN" push origin <branch>
        EOF'';
    };

    oh-my-zsh = {
      plugins = [
        "git"
        "fzf"
        "colorize"
        "z"
      ];
    };
  };
}
