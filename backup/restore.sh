#!/bin/bash
############################
# backup/restore.sh
# Restore credentials from a backup zip created by backup.sh.
#
# Usage:
#   ./backup/restore.sh tmp/backup-20260622-120000.zip
############################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

BACKUP_ZIP="${1:-}"

if [[ -z "$BACKUP_ZIP" ]]; then
    echo "=== Restore ==="
    echo ""
    echo "Usage: $0 <backup-zip>"
    echo ""
    echo "Available backups:"
    ls "$DOTFILES_DIR"/tmp/backup-*.zip 2>/dev/null | while read f; do
        echo "  $f"
    done
    echo ""
    exit 1
fi

if [[ ! -f "$BACKUP_ZIP" ]]; then
    echo "✗ File not found: $BACKUP_ZIP"
    exit 1
fi

echo "=== Restore from backup ==="
echo "Source: $BACKUP_ZIP"
echo ""

# Extract to temp dir
TMP_DIR=$(mktemp -d)
unzip -q "$BACKUP_ZIP" -d "$TMP_DIR"
# Find the extracted backup dir (backup-TIMESTAMP/)
BACKUP_DIR=$(find "$TMP_DIR" -maxdepth 1 -type d -name "backup-*" | head -1)

if [[ -z "$BACKUP_DIR" ]]; then
    echo "✗ Invalid backup zip — no backup-* directory found inside"
    rm -rf "$TMP_DIR"
    exit 1
fi

# ——— SSH keys ———
if [ -d "$BACKUP_DIR/ssh" ]; then
    echo "[1/7] Restoring SSH keys..."
    if [ -d "$HOME/.ssh" ]; then
        echo "  ⚠  ~/.ssh already exists, merging..."
        cp -rn "$BACKUP_DIR/ssh/"* "$HOME/.ssh/" 2>/dev/null || true
    else
        cp -r "$BACKUP_DIR/ssh" "$HOME/.ssh"
    fi
    chmod 700 "$HOME/.ssh"
    chmod 600 "$HOME/.ssh"/id_rsa* 2>/dev/null || true
    chmod 600 "$HOME/.ssh"/v14 2>/dev/null || true
    chmod 644 "$HOME/.ssh"/*.pub 2>/dev/null || true
    chmod 600 "$HOME/.ssh/config" 2>/dev/null || true
    echo "  → Restored ~/.ssh"
else
    echo "[1/7] No SSH keys in backup"
fi

# ——— AWS ———
if [ -d "$BACKUP_DIR/aws" ]; then
    echo "[2/7] Restoring AWS credentials..."
    cp -r "$BACKUP_DIR/aws" "$HOME/.aws"
    chmod 600 "$HOME/.aws/credentials" 2>/dev/null || true
    echo "  → Restored ~/.aws"
else
    echo "[2/7] No AWS credentials in backup"
fi

# ——— Docker ———
if [ -d "$BACKUP_DIR/docker" ]; then
    echo "[3/7] Restoring Docker config..."
    mkdir -p "$HOME/.docker"
    cp "$BACKUP_DIR/docker/config.json" "$HOME/.docker/config.json"
    echo "  → Restored ~/.docker/config.json"
else
    echo "[3/7] No Docker config in backup"
fi

# ——— mkcert ———
if [ -d "$BACKUP_DIR/mkcert" ]; then
    echo "[4/7] Restoring mkcert root CA..."
    mkdir -p "$HOME/.local/share/mkcert"
    cp -r "$BACKUP_DIR/mkcert/"* "$HOME/.local/share/mkcert/"
    echo "  → Restored ~/.local/share/mkcert"
else
    echo "[4/7] No mkcert CA in backup"
fi

# ——— GNOME Keyrings ———
if [ -d "$BACKUP_DIR/keyrings" ]; then
    echo "[5/7] Restoring GNOME keyrings..."
    mkdir -p "$HOME/.local/share/keyrings"
    cp "$BACKUP_DIR/keyrings/"* "$HOME/.local/share/keyrings/"
    echo "  → Restored ~/.local/share/keyrings"
else
    echo "[5/7] No keyrings in backup"
fi

# ——— Gitconfig local ———
if [ -f "$BACKUP_DIR/gitconfig_local" ]; then
    echo "[6/7] Restoring .gitconfig_local..."
    cp "$BACKUP_DIR/gitconfig_local" "$HOME/.gitconfig_local"
    echo "  → Restored ~/.gitconfig_local"
else
    echo "[6/7] No .gitconfig_local in backup"
fi

# ——— NPM config ———
if [ -f "$BACKUP_DIR/npmrc" ]; then
    echo "[7/7] Restoring .npmrc..."
    cp "$BACKUP_DIR/npmrc" "$HOME/.npmrc"
    echo "  → Restored ~/.npmrc"
else
    echo "[7/7] No .npmrc in backup"
fi

# ——— GNOME settings ———
echo ""
echo "Restoring GNOME settings..."
bash "$SCRIPT_DIR/gnome.sh" restore

# Cleanup
rm -rf "$TMP_DIR"

echo ""
echo "=== Restore complete ==="
echo ""
echo "You may also want to restore:"
echo "  ./backup/sticky-notes.sh restore tmp/sticky-notes-*.zip"
