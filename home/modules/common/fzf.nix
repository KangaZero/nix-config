{ pkgs, lib, ... }:
let
  c = import ./theme.nix;
  fd = lib.getExe pkgs.fd;
  batPreview = "${lib.getExe pkgs.bat} --color=always --style=numbers --line-range=:500 {}";
in
{
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    defaultCommand = "${fd} --type f --hidden --exclude .git";
    fileWidget = {
      # Ctrl-T. Was `fileWidgetCommand`; HM renamed the flat *Command/*Options
      # pairs into per-widget submodules so a widget can be overridden per shell.
      command = "${fd} --type f --hidden --exclude .git";
      options = [ "--preview '${batPreview}'" ];
    };

    # Ctrl-R belongs to atuin, not fzf. Both bind it and atuin's shell
    # integration is sourced second, so fzf's binding is dead weight that HM
    # warns about. Empty string is the documented opt-out (null would mean
    # "unset", which falls back to fzf's own default binding).
    historyWidget.command = "";

    # tokyonight-kanga — Dracula-purple accent, Tokyo Night Moon body
    defaultOptions = [
      "--color=bg+:${c.bgHighlight},bg:${c.bg},spinner:${c.blue},hl:${c.purple}"
      "--color=fg:${c.fg},header:${c.blue},info:${c.violet},pointer:${c.orange}"
      "--color=marker:${c.green},fg+:${c.fg},prompt:${c.purple},hl+:${c.purple}"
      "--color=border:${c.border},preview-bg:${c.bg},preview-fg:${c.fg}"
    ];
  };
}
