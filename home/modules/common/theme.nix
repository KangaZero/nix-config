# tokyonight-kanga — single source of truth.
# Tokyo Night Moon body + Dracula-purple accent.
# Same palette used by atuin / bat / fzf / kitty / yazi / oh-my-posh.
#
# Import as a plain attrset (no module args):
#   let c = import ./theme.nix; in ...
#
{
  # ── backgrounds / structure ──────────────────────────────────────────────
  bg = "#1e2030"; # main background (neovim / fzf / bat)
  bgTerminal = "#222436"; # kitty terminal background (slightly lighter)
  bgDark = "#212337"; # darker panels / sidebar
  bgHighlight = "#2d3f76"; # selection / current-line
  border = "#589ed7"; # widget borders

  # ── text ─────────────────────────────────────────────────────────────────
  fg = "#c8d3f5"; # primary text (kitty foreground)
  fgDark = "#828bb8"; # dimmed text / punctuation  (= muted)
  comment = "#636da6"; # code comments
  muted = "#828bb8"; # neutral grey
  dim = "#545c7e"; # receding / annotation text

  # ── accents (Dracula-purple signature) ───────────────────────────────────
  purple = "#bd93f9"; # primary accent — kitty cursor/border, prompt
  violet = "#8b5cf6"; # deeper accent — prompt borders, exec time
  blue = "#82aaff"; # functions, properties, flags
  cyan = "#86e1fc"; # support fns, string escapes
  teal = "#4fd6be"; # types / interfaces
  green = "#c3e88d"; # strings
  yellow = "#ffc777"; # warnings / find highlight
  orange = "#ff966c"; # numbers, constants, $VARs, attributes
  red = "#ff757f"; # errors, HTML tags
  magenta = "#fca7ea"; # decorators / annotations

  # ── syntax extras ────────────────────────────────────────────────────────
  operator = "#89ddff"; # operators / delimiters
  invalid = "#ff5c57"; # invalid / illegal tokens
}
