{
  username,
  userMeta,
  assetsDir,
  ...
}:
{
  imports = [
    ../../modules/common/git.nix
    ../../modules/common/direnv.nix
    ../../modules/common/firefox.nix
    ../../modules/common/kitty.nix
    ../../modules/common/yazi.nix
    ../../modules/common/neovim/neovim.nix
    ../../modules/darwin/ollama.nix
    ../../modules/common/packages/common.nix
    ../../modules/common/packages/ns-script.nix
    ../../modules/common/shell/zsh-core.nix
    ../../modules/common/slop/claude-code.nix
    ../../modules/darwin/packages.nix
    ../../modules/darwin/shell.nix
    ../../modules/common/oh-my-posh.nix
    ../../modules/darwin/discord.nix
    ../../modules/common/zellij.nix
    ../../modules/common/zoxide.nix
    ../../modules/common/lazygit.nix
  ];

  programs.kitty.settings = {
    background_image = "${assetsDir}/cat-watching-the-star_pixelart_purple_animated.gif";
    background_image_layout = "scaled";
    background_tint = "0.85";
  };

  home = {
    inherit username;
    inherit (userMeta) stateVersion;
    homeDirectory = "/Users/${username}";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables.EDITOR = "nvim";
    file.".hushlogin".text = "";
  };
}
