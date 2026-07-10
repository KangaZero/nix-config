{ username, hostname, ... }: {
  programs.zsh.shellAliases = {
    edit-nix = "cd /home/${username}/.config/multi-nix && nvim flake.nix";
    home-switch = "home-manager switch --flake /home/${username}/.config/multi-nix#${username}";
    nix-switch = "sudo nixos-rebuild switch --flake /home/${username}/.config/multi-nix#${hostname}";
    nh-switch = "nh os switch /home/${username}/.config/multi-nix#${hostname}";
    nh-build = "nh os build /home/${username}/.config/multi-nix#${hostname}";
    nvim-dev = "NVIM_APPNAME=multi-nix/home/modules/common/neovim/config nvim";
  };
}
