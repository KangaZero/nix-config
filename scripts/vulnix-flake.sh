#!/usr/bin/env bash
set -euo pipefail

#INFO: BASH_SOURCE is script's own path
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"

cd "$REPO_DIR"

if [[ $(uname) == "Linux" ]]; then
	nix build .#nixosConfigurations.nixos.config.system.build.toplevel
else
	darwin-rebuild build --flake .#samuelwaiweng
fi

REPORT="$REPO_DIR/CVE_REPORT.md"
echo "## $(date '+%Y-%m-%d %H:%M:%S %Z')" > "$REPORT"
echo "" >> "$REPORT"

if command -v vulnix &>/dev/null; then
  vulnix result/ | tee -a "$REPORT"
else
  nix run nixpkgs#vulnix -- result/ | tee -a "$REPORT"
fi
