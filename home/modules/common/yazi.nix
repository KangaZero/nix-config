{ pkgs, ... }:
let
  # Tokyo Night flavor — matches the kitty tokyonight-moon palette.
  # Rev/hash pinned; refresh with:
  #   nix run nixpkgs#nix-prefetch-github -- BennyOe tokyo-night.yazi
  tokyo-night = pkgs.fetchFromGitHub {
    owner = "BennyOe";
    repo = "tokyo-night.yazi";
    rev = "8e6296f14daff24151c736ebd0b9b6cd89b02b03";
    hash = "sha256-LArhRteD7OQRBguV1n13gb5jkl90sOxShkDzgEf3PA0=";
  };
in
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    # -> ~/.config/yazi/yazi.toml
    settings = {
      mgr = {
        ratio = [
          1
          4
          3
        ];
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "size";
        show_hidden = true;
        show_symlink = true;
        scrolloff = 5;
        mouse_events = [
          "click"
          "scroll"
        ];
        title_format = "Yazi: {cwd}";
      };

      preview = {
        wrap = "no";
        tab_size = 2;
        max_width = 600;
        max_height = 900;
        image_delay = 30;
        image_filter = "triangle";
        image_quality = 75;
      };
    };

    # -> ~/.config/yazi/keymap.toml (prepended before yazi's defaults)
    keymap = {
      mgr.prepend_keymap = [
        {
          on = [
            "g"
            "h"
          ];
          run = "cd ~";
          desc = "Go home";
        }
        {
          on = [
            "g"
            "c"
          ];
          run = "cd ~/.config";
          desc = "Go to ~/.config";
        }
        {
          on = [
            "g"
            "d"
          ];
          run = "cd ~/Downloads";
          desc = "Go to ~/Downloads";
        }
        {
          on = ".";
          run = "hidden toggle";
          desc = "Toggle hidden files";
        }
        {
          on = "<C-r>";
          run = "refresh";
          desc = "Refresh listing";
        }
        {
          on = "!";
          run = ''shell "$SHELL" --block'';
          desc = "Open shell here";
        }
      ];
    };

    # -> ~/.config/yazi/theme.toml
    theme.flavor = {
      dark = "tokyo-night";
      light = "tokyo-night";
    };

    # -> ~/.config/yazi/flavors/tokyo-night.yazi
    flavors."tokyo-night" = tokyo-night;
  };

}
