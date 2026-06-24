#!/usr/bin/env bash
set -euo pipefail

# BASH_SOURCE[0] = script path; -- protects against dirs starting with -
REPO_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"

cd "$REPO_DIR"

OS="$(uname)"

if [[ "$OS" == "Linux" ]]; then
	nix build .#nixosConfigurations.nixos.config.system.build.toplevel
	REPORT="$REPO_DIR/CVE_REPORT_WSL.md"
elif [[ "$OS" == "Darwin" ]]; then
	nix build .#darwinConfigurations.KangaZero.system
	REPORT="$REPO_DIR/CVE_REPORT_DARWIN.md"
else
	echo "Unsupported platform: $OS" >&2
	exit 1
fi

echo "## $(date '+%Y-%m-%d %H:%M:%S %Z')" > "$REPORT"
echo "" >> "$REPORT"

if command -v vulnix &>/dev/null; then
	vulnix result/ | tee -a "$REPORT"
else
	nix run nixpkgs#vulnix -- result/ | tee -a "$REPORT"
fi
