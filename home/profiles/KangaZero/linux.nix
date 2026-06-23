{
  username,
  userMeta,
  assetsDir,
  lib,
  ...
}:
{
  imports = [
    ../../modules/common/git.nix
    ../../modules/common/direnv.nix
    ../../modules/common/firefox.nix
    ../../modules/common/kitty.nix
    ../../modules/common/neovim/neovim.nix
    ../../modules/common/packages/common.nix
    ../../modules/common/packages/ns-script.nix
    ../../modules/common/shell/zsh-core.nix
    ../../modules/common/zellij.nix
    ../../modules/common/zoxide.nix
    ../../modules/common/lazygit.nix
    ../../modules/linux/ollama.nix
    ../../modules/linux/packages.nix
    ../../modules/linux/bash.nix
    ../../modules/linux/shell.nix
    ../../modules/linux/weston.nix
    ../../modules/linux/wayland/niri/default.nix
  ];

  programs = {
    kitty.settings = {
      background_image = "${assetsDir}/moon_dark.png";
      background_image_layout = "scaled";
      background_tint = "0.85";
    };
    # Override userMeta.git.personal
    git.settings.user = {
      name = lib.mkForce userMeta.git.work.name;
      email = lib.mkForce userMeta.git.work.email;
    };
  };

  home = {
    inherit username;
    inherit (userMeta) stateVersion;
    homeDirectory = "/home/${username}";
    keyboard.layout = "us";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      EDITOR = "nvim";
      LIBGL_ALWAYS_SOFTWARE = "1";
    };
  };

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
}
