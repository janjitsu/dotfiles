#!/bin/bash
############################
# bootstrap.sh
# One-liner bootstrap for a fresh machine. No git required.
# Downloads the repo as a tarball from GitHub and runs setup.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/janjitsu/dotfiles/main/bootstrap.sh | bash
#
# Any arguments are forwarded to setup.sh, e.g.:
#   curl -fsSL .../bootstrap.sh | bash -s -- --no-desktop
############################

set -euo pipefail

REPO="janjitsu/dotfiles"
BRANCH="main"
DOTFILES_DIR="$HOME/dotfiles"
TARBALL_URL="https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz"

echo "=== Dotfiles Bootstrap ==="
echo ""

# ——— Step 1: Download and extract ———
echo "[1/2] Downloading dotfiles..."

if [ -d "$DOTFILES_DIR" ]; then
    echo "  ⚠  $DOTFILES_DIR already exists, backing up to ${DOTFILES_DIR}.bak"
    mv "$DOTFILES_DIR" "${DOTFILES_DIR}.bak.$(date +%s)"
fi

TMP_FILE=$(mktemp /tmp/dotfiles-XXXXXX)
curl -fsSL -o "$TMP_FILE" "$TARBALL_URL"

# GitHub tarballs extract to repo-branch/, move to ~/dotfiles
TMP_EXTRACT=$(mktemp -d /tmp/dotfiles-extract-XXXXXX)
tar -xzf "$TMP_FILE" -C "$TMP_EXTRACT"
mv "$TMP_EXTRACT"/*/ "$DOTFILES_DIR"
rm -rf "$TMP_FILE" "$TMP_EXTRACT"

echo "  → Extracted to $DOTFILES_DIR"

# ——— Step 2: Run setup ———
echo "[2/2] Running setup..."
cd "$DOTFILES_DIR"
bash setup.sh "$@"

# After setup, git is installed — init the repo so you can push/pull
if command -v git &>/dev/null; then
    cd "$DOTFILES_DIR"
    git init
    git remote add origin "git@github.com:$REPO.git"
    git fetch
    git reset origin/$BRANCH
    echo ""
    echo "→ Git repo initialized with remote origin"
fi

echo ""
echo "=== Bootstrap complete ==="
