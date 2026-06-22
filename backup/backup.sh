#!/bin/bash
############################
# backup/backup.sh
# Unified backup — run this before reinstalling.
# Creates a timestamped backup zip in tmp/ with all sensitive data.
############################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$DOTFILES_DIR/tmp/backup-$TIMESTAMP"

mkdir -p "$BACKUP_DIR"

echo "=== Full Backup ==="
echo "Date: $(date)"
echo "Target: $BACKUP_DIR"
echo ""

# ——— Step 1: GNOME settings ———
echo "[1/5] Backing up GNOME settings..."
bash "$SCRIPT_DIR/gnome.sh" backup
echo ""

# ——— Step 2: Sticky notes ———
echo "[2/5] Backing up sticky notes..."
bash "$SCRIPT_DIR/sticky-notes.sh" backup
echo ""

# ——— Step 3: SSH keys ———
echo "[3/5] Backing up SSH keys..."
if [ -d "$HOME/.ssh" ]; then
    cp -r "$HOME/.ssh" "$BACKUP_DIR/ssh"
    echo "  → Copied ~/.ssh"
else
    echo "  ⚠  No ~/.ssh found"
fi

# ——— Step 4: Credentials ———
echo ""
echo "[4/5] Backing up credentials..."

# AWS
if [ -d "$HOME/.aws" ]; then
    cp -r "$HOME/.aws" "$BACKUP_DIR/aws"
    echo "  → Copied ~/.aws (config + credentials)"
fi

# Docker
if [ -f "$HOME/.docker/config.json" ]; then
    mkdir -p "$BACKUP_DIR/docker"
    cp "$HOME/.docker/config.json" "$BACKUP_DIR/docker/config.json"
    echo "  → Copied ~/.docker/config.json"
fi

# mkcert CA
if [ -d "$HOME/.local/share/mkcert" ]; then
    cp -r "$HOME/.local/share/mkcert" "$BACKUP_DIR/mkcert"
    echo "  → Copied mkcert root CA"
fi

# GNOME Keyring
if [ -f "$HOME/.local/share/keyrings/login.keyring" ]; then
    mkdir -p "$BACKUP_DIR/keyrings"
    cp "$HOME/.local/share/keyrings/login.keyring" "$BACKUP_DIR/keyrings/"
    cp "$HOME/.local/share/keyrings/user.keystore" "$BACKUP_DIR/keyrings/" 2>/dev/null || true
    echo "  → Copied GNOME keyrings"
fi

# Gitconfig local
if [ -f "$HOME/.gitconfig_local" ]; then
    cp "$HOME/.gitconfig_local" "$BACKUP_DIR/gitconfig_local"
    echo "  → Copied .gitconfig_local"
fi

# NPM config
if [ -f "$HOME/.npmrc" ]; then
    cp "$HOME/.npmrc" "$BACKUP_DIR/npmrc"
    echo "  → Copied .npmrc"
fi

# ——— Step 5: Create zip ———
echo ""
echo "[5/5] Creating backup archive..."
BACKUP_ZIP="$DOTFILES_DIR/tmp/backup-$TIMESTAMP.zip"
cd "$DOTFILES_DIR/tmp"
zip -r -q "backup-$TIMESTAMP.zip" "backup-$TIMESTAMP/"
rm -rf "$BACKUP_DIR"

echo "  → $BACKUP_ZIP"

echo ""
echo "=== Backup complete ==="
echo ""
echo "⚠  This zip contains sensitive data (SSH keys, AWS creds, tokens)."
echo "   Store it somewhere safe. Do NOT commit it to git."
echo ""
echo "Next steps:"
echo "  1. Copy $BACKUP_ZIP to a USB drive or secure cloud storage"
echo "  2. Review the CHECKLIST: $SCRIPT_DIR/CHECKLIST.md"
echo "  3. Reinstall and run: curl -fsSL https://raw.githubusercontent.com/janjitsu/dotfiles/master/bootstrap.sh | bash"
echo "  4. Restore credentials from the backup zip"
