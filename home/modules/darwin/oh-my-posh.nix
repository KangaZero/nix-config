{ ... }:
{
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    configFile = "~/.config/oh-my-posh/config.toml";
  };
}
