#!/usr/bin/env bash
# Load the entire config headlessly and fail on any error.
#   load-test.sh             -> load using the current environment (fast; plugins cached)
#   load-test.sh --isolated  -> load in a throwaway XDG env (fresh plugin clone; for CI)
set -euo pipefail

here="$(cd "$(dirname "$0")/.." && pwd)"
err_re='[Ee]rror|E[0-9]{2,}:|stack traceback'

if [[ "${1:-}" == "--isolated" ]]; then
	tmp="$(mktemp -d)"
	trap 'rm -rf "$tmp"' EXIT
	mkdir -p "$tmp/config/nvim" "$tmp/data" "$tmp/state" "$tmp/cache"
	cp -a "$here/." "$tmp/config/nvim/"
	export XDG_CONFIG_HOME="$tmp/config" XDG_DATA_HOME="$tmp/data" \
		XDG_STATE_HOME="$tmp/state" XDG_CACHE_HOME="$tmp/cache"
	echo "==> isolated load (fresh plugin clone under $tmp)"
else
	echo "==> load using current environment"
fi

out="$(nvim --headless -c 'qa!' 2>&1 || true)"

if echo "$out" | grep -qE "$err_re"; then
	echo "LOAD FAILED:"
	echo "$out"
	exit 1
fi

echo "load OK"
[ -n "$out" ] && { echo "--- non-fatal output:"; echo "$out"; }
exit 0
