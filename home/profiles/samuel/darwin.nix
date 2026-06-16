{ username, userMeta, assetsDir, ... }:
{
  imports = [
    ../../modules/common/git.nix
    ../../modules/common/direnv.nix
    ../../modules/common/firefox.nix
    ../../modules/common/kitty.nix
    ../../modules/common/neovim.nix
    ../../modules/common/packages/common.nix
    ../../modules/common/packages/ns-script.nix
    ../../modules/common/shell/zsh-core.nix
    ../../modules/darwin/packages.nix
    ../../modules/darwin/shell.nix
    ../../modules/darwin/oh-my-posh.nix
    ../../modules/darwin/discord.nix
    ../../modules/darwin/zellij.nix
    ../../modules/darwin/zoxide.nix
    ../../modules/darwin/lazygit.nix
  ];

  programs.kitty.settings.background_image = "${assetsDir}/cat-watching-the-star_pixelart_purple_animated.gif";
  programs.kitty.settings.background_image_layout = "scaled";
  programs.kitty.settings.background_tint = "0.85";

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = userMeta.stateVersion;
    sessionVariables.EDITOR = "nvim";
    file.".hushlogin".text = "";
    shell.enableZshIntegration = true;
  };
}
