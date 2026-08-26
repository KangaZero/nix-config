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
    # Manual GC. programs.nh.clean.extraArgs only reaches the systemd timer, so
    # a hand-typed `nh clean all` still reaps .direnv gcroots and kills every
    # git-hooks.nix pre-commit install. Alias it so the manual path can't drift
    # from the retention policy in modules/nixos/nh.nix.
    nh-clean = "nh clean all --keep 3 --keep-since 7d --keep-one";
    # Preview before committing to a sweep — nh prints every DEL/OK decision.
    nh-clean-dry = "nh clean all --keep 3 --keep-since 7d --keep-one --dry";
    nvim-dev = "NVIM_APPNAME=multi-nix/home/modules/common/neovim/config nvim";
  };
}
