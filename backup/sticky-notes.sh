#!/bin/bash
############################
# backup/sticky-notes.sh
# Backup and restore indicator-stickynotes data.
#
# The notes file contains sensitive content, so it's zipped into
# the tmp/ folder which is gitignored. Store the zip elsewhere.
#
# Usage:
#   Backup:  ./backup/sticky-notes.sh backup [output.zip]
#   Restore: ./backup/sticky-notes.sh restore <input.zip>
############################

set -euo pipefail

NOTES_FILE="$HOME/.config/indicator-stickynotes"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
DEFAULT_ZIP="$DOTFILES_DIR/tmp/sticky-notes-$(date +%Y%m%d).zip"

usage() {
    echo "Usage:"
    echo "  $0 backup  [output.zip]   Create zip of sticky notes (default: tmp/)"
    echo "  $0 restore <input.zip>    Restore sticky notes from zip"
    echo ""
    echo "Default backup file: $DEFAULT_ZIP"
    exit 1
}

backup() {
    local output="${1:-$DEFAULT_ZIP}"
    mkdir -p "$(dirname "$output")"

    if [[ ! -f "$NOTES_FILE" ]]; then
        echo "✗ Sticky notes file not found: $NOTES_FILE"
        exit 1
    fi

    echo "=== Sticky Notes Backup ==="
    echo "Source: $NOTES_FILE"
    echo "Output: $output"
    echo ""

    zip -j "$output" "$NOTES_FILE"

    echo ""
    echo "=== Backup complete ==="
    echo "Store this file somewhere safe (NOT in the repo)."
}

restore() {
    local input="$1"

    if [[ ! -f "$input" ]]; then
        echo "✗ File not found: $input"
        exit 1
    fi

    echo "=== Sticky Notes Restore ==="
    echo "Source: $input"
    echo "Target: $NOTES_FILE"
    echo ""

    # Back up existing notes if present
    if [[ -f "$NOTES_FILE" ]]; then
        local bak="${NOTES_FILE}.bak.$(date +%s)"
        cp "$NOTES_FILE" "$bak"
        echo "Existing notes backed up to: $bak"
    fi

    unzip -o -d "$(dirname "$NOTES_FILE")" "$input"

    echo ""
    echo "=== Restore complete ==="
    echo "Restart indicator-stickynotes for changes to take effect."
}

# ——— Main ———
[[ $# -lt 1 ]] && usage

case "$1" in
    backup)  backup "${2:-}" ;;
    restore)
        [[ $# -lt 2 ]] && { echo "✗ restore requires a zip file path"; usage; }
        restore "$2"
        ;;
    *) usage ;;
esac
