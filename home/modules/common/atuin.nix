_:
let
  # Tokyo Night Moon body + Dracula-purple accent — same palette as
  # kitty.nix / yazi.nix / oh-my-posh.toml. Keep these in sync by hand.
  palette = {
    purple = "#bd93f9"; # signature accent (kitty cursor + border, prompt)
    violet = "#8b5cf6"; # deeper accent (prompt borders, exec time)
    fg = "#c8d3f5"; # kitty foreground
    blue = "#82aaff";
    yellow = "#ffc777";
    green = "#c3e88d";
    red = "#ff757f";
    orange = "#ff966c";
    cyan = "#86e1fc";
    muted = "#828bb8";
    dim = "#545c7e";
  };
in
{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;

    # -> ~/.config/atuin/config.toml
    settings = {
      dialect = "uk";
      auto_sync = false; # set to true if using online
      update_check = false; # set to true if using online
      search_mode = "fuzzy";
      keymap_mode = "vim-normal";
      # Selects themes."tokyonight-kanga" below.
      theme.name = "tokyonight-kanga";
    };

    # -> ~/.config/atuin/themes/<name>.toml
    # https://docs.atuin.sh/latest/guide/theming/#theme-structure
    themes."tokyonight-kanga" = {
      theme = {
        name = "Tokyo Night Kanga";
        # Unlisted meanings inherit from this builtin theme.
        parent = "default";
      };

      colors = with palette; {
        # --- structure ---
        Base = fg; # default foreground
        Title = purple; # section / view titles
        Important = violet; # attention-drawing text
        Annotation = dim; # supporting, less-critical text
        Guidance = muted; # help / instructional text
        Muted = dim; # neutral grey contrast

        # --- alerts ---
        AlertInfo = blue;
        AlertWarn = yellow;
        AlertError = red;

        # --- shell syntax (history entries in the Ctrl-R TUI) ---
        # red/yellow deliberately unused here — they stay reserved for
        # AlertError/AlertWarn so a real alert still reads as an alert.
        SyntaxCommand = purple; # accent: the word you scan for
        SyntaxFlag = blue; # -f / --flag
        SyntaxString = green; # quoted strings
        SyntaxVariable = orange; # $VAR / VAR=…
        SyntaxOperator = cyan; # | && ; >  — frequent, so kept calm
        SyntaxComment = dim; # recedes
      };
    };
  };
}
