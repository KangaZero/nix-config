{ username, hostname, ... }: {
  programs.zsh.shellAliases = {
    edit-nix = "cd /home/${username}/.config/multi-nix && nvim flake.nix";
    home-switch = "home-manager switch --flake /home/${username}/.config/multi-nix#${username}";
    nix-switch = "sudo nixos-rebuild switch --flake /home/${username}/.config/multi-nix#${hostname}";
    # Primary rebuild path. No flake argument needed: programs.nh.flake exports
    # NH_FLAKE and nh resolves the attribute from the running hostname.
    nh-switch = "nh os switch";
    nh-build = "nh os build";
    nh-test = "nh os test";
    nh-boot = "nh os boot";
    nh-rollback = "nh os rollback";
    nh-info = "nh os info";
    nvim-dev = "NVIM_APPNAME=multi-nix/home/modules/common/neovim/config nvim";
  };
}
