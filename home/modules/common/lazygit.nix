_:
let
  c = import ./theme.nix;
in
{
  programs.lazygit = {
    enable = true;
    settings.gui.theme = {
      lightTheme = false;
      activeBorderColor = [
        c.purple
        "bold"
      ];
      inactiveBorderColor = [ c.bgHighlight ];
      optionsTextColor = [ c.blue ];
      selectedLineBgColor = [ c.bgHighlight ];
      selectedRangeBgColor = [ c.bgHighlight ];
      cherryPickedCommitBgColor = [ c.violet ];
      cherryPickedCommitFgColor = [ c.fg ];
      unstagedChangesColor = [ c.red ];
      defaultFgColor = [ c.fg ];
    };
  };
}
