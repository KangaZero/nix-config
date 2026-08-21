#!/usr/bin/env bash
set -euo pipefail

# BASH_SOURCE[0] = script path; -- protects against dirs starting with -
REPO_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"

cd "$REPO_DIR"

OS="$(uname)"

case "$OS" in
Linux)
	BUILD_ATTR=".#nixosConfigurations.nixos.config.system.build.toplevel"
	REPORT="$REPO_DIR/CVE_REPORT_WSL.md"
	;;
Darwin)
	BUILD_ATTR=".#darwinConfigurations.KangaZero.system"
	REPORT="$REPO_DIR/CVE_REPORT_DARWIN.md"
	;;
*)
	echo "Unsupported platform: $OS" >&2
	exit 1
	;;
esac

nix build "$BUILD_ATTR"

# Build the report in a temp file and only replace $REPORT once vulnix has
# actually produced a scan. Writing the header straight to $REPORT truncated the
# previous report before vulnix ran, so any failure (an NVD download timeout is
# enough) left behind a two-line file with the old findings gone.
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

printf '## %s\n\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')" >"$TMP"

if command -v vulnix &>/dev/null; then
	VULNIX=(vulnix)
else
	VULNIX=(nix run nixpkgs#vulnix --)
fi

# vulnix exit codes (vulnix/output.py): 0 = clean, 1 = whitelisted findings only,
# 2 = active advisories, 3 = no scan target given. Findings are the *expected*
# outcome here, so 0-2 all count as success - `set -e` aborting on a 2 is what
# made the weekly workflow fail on every run despite producing a good report.
set +e
"${VULNIX[@]}" result/ | tee -a "$TMP"
status="${PIPESTATUS[0]}"
set -e

case "$status" in
0 | 1 | 2) ;;
*)
	echo "vulnix failed (exit $status) - keeping the existing $(basename "$REPORT")" >&2
	exit "$status"
	;;
esac

# A RuntimeError inside vulnix also exits 2, so the code alone can't prove the
# scan finished. Require the summary line before overwriting a good report.
if ! grep -qE 'derivations with active advisories|Found no advisories' "$TMP"; then
	echo "vulnix produced no scan summary - keeping the existing $(basename "$REPORT")" >&2
	exit 1
fi

# mktemp creates 0600; the report is committed and read by anyone.
chmod 644 "$TMP"
mv "$TMP" "$REPORT"

echo "wrote $REPORT"
