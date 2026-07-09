{ lib, ... }:
# nixpkgs contribution helpers, shared across all machines.
#
# Aliases are prefix-style (args append to the right command); anything that
# needs an argument in the middle is a shell function further down.
#
# ============================================================================
# WORKFLOW — which helper to run at each step (create / update / test / PR)
# ============================================================================
#   0. Clone nixpkgs once:      nclone            (full history + lazy blobs)
#      then per change:         git fetch upstream master
#                               git checkout -b <pkg>-<newver> upstream/master
#
#   -- UPDATE an existing package --
#   1. Bump + refresh hashes:   nbump <attr> [--version <ver>]   (uses nix-update)
#         (or edit `version` by hand, set each hash to `lib.fakeHash`, then build)
#
#   -- CREATE a new package --
#   1. Write pkgs/by-name/<xx>/<name>/package.nix  (hashes = lib.fakeHash)
#   2. Jump into its dir:       ncd <name>
#
#   -- TEST / RUN (both cases) --
#   3. Build:                   nb <attr>         (nbl = build, no ./result link)
#         (fake-hash flow: build, copy the `got:` hash from the error, paste, rebuild)
#   4. Run the binary:          ./result/bin/<x>   or   nrun .#<attr>
#   5. Eval sanity (no build):  nev .#<attr>.version
#   6. Reverse-dep build:       nreview            (rev HEAD; nreviewpr <n> = a PR)
#
#   -- QUALITY GATES (match CI/ofborg) --
#   7. Format:                  nfmt <file>        (nfmtc = --check)
#   8. Lint:                    nstatix <path>  ·  ndeadnix <path>  ·  neditorcheck <path>
#
#   -- COMMIT / PR --
#   9. git commit -m "<attr>: <old> -> <new>"      (no trailing period;
#         add `--trailer "Assisted-by: <tool/model>"` if AI-assisted — nixpkgs policy)
#  10. push to your fork, then: gh pr create --repo NixOS/nixpkgs --base master ...
#         ofborg then builds the package automatically on the PR.
#
#   Handy: nprefetchgh <owner> <repo> <tag>  ->  SRI hash for a fetchFromGitHub src
# ============================================================================
{
  programs.zsh.shellAliases = {
    # Build / run / eval a package attr from inside a nixpkgs checkout.
    nb = "nix-build -A"; # nb hello
    nbl = "nix-build --no-out-link -A"; # build, no ./result symlink
    nrun = "nix run"; # nrun .#hello
    nsp = "nix-shell -p"; # ephemeral shell with pkg(s): nsp hello
    nev = "nix eval"; # nev .#hello.version

    # Clone nixpkgs the right way: full commit history (so nixpkgs-review's
    # merge works) but lazy blob fetching (small). NOT --depth 1.
    nclone = "git clone --filter=blob:none https://github.com/NixOS/nixpkgs";

    # Local reviewer build of the current commit (needs a full-history clone).
    nreview = "nix-shell -p nixpkgs-review --run \"nixpkgs-review rev HEAD\"";
  };

  # Functions: these interpolate arguments, so they can't be plain aliases.
  # Appended after the core zsh init (mkAfter) so it merges cleanly.
  programs.zsh.initContent = lib.mkAfter ''
    # --- nixpkgs contribution helpers (functions) ---

    # Bump version + refresh all hashes (src + npmDepsHash/cargoHash/vendorHash).
    #   nbump <attr>                  (update to latest)
    #   nbump <attr> --version <ver>  (update to a specific version)
    nbump() { nix-shell -p nix-update --run "nix-update $*"; }

    # Format / check-format nix files with the nixpkgs formatter (pkgs.nixfmt).
    #   nfmt <file...>   |   nfmtc <file...>
    nfmt()  { nix-shell -p nixfmt --run "nixfmt $*"; }
    nfmtc() { nix-shell -p nixfmt --run "nixfmt --check $*"; }

    # Linters (take a path).
    nstatix()      { nix-shell -p statix --run "statix check $*"; }
    ndeadnix()     { nix-shell -p deadnix --run "deadnix $*"; }
    neditorcheck() { nix-shell -p editorconfig-checker --run "editorconfig-checker $*"; }

    # Reviewer build of an upstream PR by number: nreviewpr <pr-number>
    nreviewpr() { nix-shell -p nixpkgs-review --run "nixpkgs-review pr $*"; }

    # Prefetch a GitHub tag tarball as an SRI hash: nprefetchgh <owner> <repo> <tag>
    nprefetchgh() {
      local h
      h=$(nix-prefetch-url --unpack "https://github.com/$1/$2/archive/refs/tags/$3.tar.gz" 2>/dev/null | tail -1) || return 1
      nix hash convert --hash-algo sha256 --to sri "$h"
    }

    # cd to a by-name package dir from a nixpkgs checkout: ncd <attr>
    ncd() {
      local n="$1" root
      root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "not in a git repo"; return 1; }
      cd "$root/pkgs/by-name/$(printf %.2s "$n")/$n" 2>/dev/null || echo "no by-name dir for '$n'"
    }
  '';
}
