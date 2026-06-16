{ ... }:
{
  programs.lazygit = {
    enable = true;
    enableZshIntegration = true;
    settings.gui.theme = {
      lightTheme = true;
      activeBorderColor = [ "blue" "bold" ];
      inactiveBorderColor = [ "black" ];
      selectedLineBgColor = [ "default" ];
    };
  };
}
