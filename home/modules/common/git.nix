{ userMeta, ... }:
let
  c = import ./theme.nix;
in
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [
      "**/.DS_Store"
      ".direnv/"
    ];
    settings = {
      user = {
        name = userMeta.git.personal.name;
        email = userMeta.git.personal.email;
      };
      github.user = userMeta.githubUser;
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase.autoStash = true;
      core = {
        autocrlf = "input";
        editor = "nvim";
        # core.pager is set automatically by programs.delta.enableGitIntegration
      };
    };
  };

  # Top-level module, not `programs.git.delta` — HM moved delta out so it can
  # also drive jujutsu. The old path still resolves through a rename shim but
  # warns on every eval.
  programs.delta = {
    enable = true;

    # Must be explicit. With only the legacy `programs.git.delta.enable` set, HM
    # inferred this at mkOverride 1490 and warned about the inference.
    # delta wires core.pager + interactive.diffFilter automatically.
    enableGitIntegration = true;

    # syntax-theme resolves from programs.bat.themes at runtime.
    options = {
      syntax-theme = "tokyonight-kanga";
      dark = true;
      side-by-side = true;
      line-numbers = true;
      navigate = true; # n/N jumps between diff hunks

      # ── file header ──────────────────────────────────────────────────
      file-style = "bold ${c.blue}";
      file-decoration-style = "${c.blue} ul";

      # ── hunk header ───────────────────────────────────────────────────
      hunk-header-style = "file line-number syntax";
      hunk-header-decoration-style = "${c.bgHighlight} box";

      # ── diff backgrounds (dark tints — tokyonight moon diff palette) ──
      # Not in theme.nix: too diff-specific to pollute the shared palette.
      minus-style = "syntax \"#37222c\""; # removed line bg
      minus-emph-style = "syntax \"#5d2a2c\""; # removed word bg
      plus-style = "syntax \"#1c3b20\""; # added line bg
      plus-emph-style = "syntax \"#266d32\""; # added word bg

      # ── line numbers ──────────────────────────────────────────────────
      line-numbers-minus-style = c.red;
      line-numbers-plus-style = c.green;
      line-numbers-zero-style = c.comment;
      line-numbers-left-style = c.bgHighlight;
      line-numbers-right-style = c.bgHighlight;
    };
  };
}
