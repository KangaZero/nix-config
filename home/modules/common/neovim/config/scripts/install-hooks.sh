#!/usr/bin/env bash
# Symlink the versioned pre-commit hook into .git/hooks so edits to the
# tracked hook take effect immediately. Idempotent.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
src="$root/home/modules/common/neovim/config/scripts/hooks/pre-commit"
dst="$root/.git/hooks/pre-commit"

chmod +x "$src"
ln -sf "$src" "$dst"
echo "Installed pre-commit hook:"
echo "  $dst -> $src"
