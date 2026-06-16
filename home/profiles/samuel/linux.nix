{ username, userMeta, ... }:
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
    ../../modules/linux/packages.nix
    ../../modules/linux/bash.nix
    ../../modules/linux/shell.nix
    ../../modules/linux/weston.nix
    ../../modules/linux/wayland/niri/default.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = userMeta.stateVersion;
    keyboard.layout = "us";
    sessionVariables = {
      EDITOR = "nvim";
      LIBGL_ALWAYS_SOFTWARE = "1";
    };
  };

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
}
