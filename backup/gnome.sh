#!/bin/bash
############################
# backup/gnome.sh
# Backup and restore GNOME desktop environment settings.
# Artifacts are stored in dotfiles/gnome/ (committed to the repo).
#
# Usage:
#   Backup:  ./backup/gnome.sh backup
#   Restore: ./backup/gnome.sh restore
############################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
GNOME_DIR="$DOTFILES_DIR/gnome"
DCONF_DIR="$GNOME_DIR/dconf"

# Extensions that ship with Ubuntu — no need to back these up
SYSTEM_EXTENSIONS=(
    "ding@rastersoft.com"
    "ubuntu-appindicators@ubuntu.com"
    "ubuntu-dock@ubuntu.com"
)

is_system_extension() {
    local ext="$1"
    for sys_ext in "${SYSTEM_EXTENSIONS[@]}"; do
        [[ "$ext" == "$sys_ext" ]] && return 0
    done
    return 1
}

usage() {
    echo "Usage:"
    echo "  $0 backup    Snapshot current GNOME settings into gnome/"
    echo "  $0 restore   Restore GNOME settings from gnome/"
    exit 1
}

# ——————————————————————————————————————————————————
# BACKUP
# ——————————————————————————————————————————————————
do_backup() {
    echo "=== GNOME Desktop Backup ==="
    echo ""

    # ——— Step 1: Extension lists ———
    echo "[1/3] Exporting extension lists..."

    {
        echo "# GNOME Shell Extensions — Enabled"
        echo "# Generated: $(date -Iseconds)"
        echo "# Use '$0 restore' to reinstall from extensions.gnome.org"
        echo ""
        gnome-extensions list --enabled 2>/dev/null | while read -r ext; do
            is_system_extension "$ext" || echo "$ext"
        done
    } > "$GNOME_DIR/extensions-enabled.list"

    {
        echo "# GNOME Shell Extensions — Disabled"
        echo "# Generated: $(date -Iseconds)"
        echo ""
        gnome-extensions list --disabled 2>/dev/null | while read -r ext; do
            is_system_extension "$ext" || echo "$ext"
        done
    } > "$GNOME_DIR/extensions-disabled.list"

    enabled_count=$(grep -cve '^#\|^$' "$GNOME_DIR/extensions-enabled.list" || true)
    disabled_count=$(grep -cve '^#\|^$' "$GNOME_DIR/extensions-disabled.list" || true)
    echo "  → ${enabled_count:-0} enabled, ${disabled_count:-0} disabled"

    # ——— Step 2: dconf dumps ———
    echo "[2/3] Dumping dconf settings..."
    mkdir -p "$DCONF_DIR"

    dconf dump /org/gnome/shell/extensions/ > "$DCONF_DIR/extensions.dconf"
    echo "  → Extension configs"

    dconf dump /org/gnome/shell/ > "$DCONF_DIR/shell.dconf"
    echo "  → Shell settings (favorites, enabled-extensions, overview…)"

    dconf dump /org/gnome/desktop/ > "$DCONF_DIR/desktop.dconf"
    echo "  → Desktop settings (theme, fonts, interface, wm…)"

    dconf dump /org/gnome/terminal/ > "$DCONF_DIR/terminal.dconf"
    echo "  → Terminal profiles"

    # ——— Step 3: Keybindings (existing Perl script) ———
    echo "[3/3] Exporting keybindings..."
    if [[ -f "$SCRIPT_DIR/gnome_keybindings.pl" ]]; then
        perl "$SCRIPT_DIR/gnome_keybindings.pl" -e "$GNOME_DIR/gsettings.csv"
        echo "  → gsettings.csv updated"
    else
        echo "  ⚠  gnome_keybindings.pl not found, skipping"
    fi

    echo ""
    echo "=== Backup complete ==="
    echo "Files in: $GNOME_DIR/"
    echo "Don't forget to commit."
}

# ——————————————————————————————————————————————————
# RESTORE
# ——————————————————————————————————————————————————

install_extension() {
    local uuid="$1"
    printf "  → %-55s" "$uuid"

    # Check if already installed
    if gnome-extensions info "$uuid" &>/dev/null; then
        echo "[already installed]"
        return 0
    fi

    # Query extensions.gnome.org
    local shell_version
    shell_version=$(gnome-shell --version | awk '{print $3}' | cut -d. -f1)

    local info
    info=$(curl -sf "https://extensions.gnome.org/extension-info/?uuid=${uuid}&shell_version=${shell_version}" 2>/dev/null) || {
        echo "[not found on e.g.o]"
        return 1
    }

    # Extract download URL
    local download_url
    download_url=$(echo "$info" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if 'download_url' in data:
    print(data['download_url'])
else:
    sys.exit(1)
" 2>/dev/null) || {
        echo "[no compatible version]"
        return 1
    }

    # Download and install
    local tmp_zip
    tmp_zip=$(mktemp /tmp/gnome-ext-XXXXXX.zip)
    if curl -sL -o "$tmp_zip" "https://extensions.gnome.org${download_url}" \
       && gnome-extensions install --force "$tmp_zip" 2>/dev/null; then
        echo "[installed]"
    else
        echo "[FAILED]"
        rm -f "$tmp_zip"
        return 1
    fi
    rm -f "$tmp_zip"
    return 0
}

do_restore() {
    echo "=== GNOME Desktop Restore ==="
    echo ""

    # ——— Step 1: Install extensions ———
    echo "[1/4] Installing extensions..."

    local shell_version
    shell_version=$(gnome-shell --version | awk '{print $3}' | cut -d. -f1)
    echo "  GNOME Shell version: $shell_version"

    failed=()

    for list_file in "$GNOME_DIR/extensions-enabled.list" "$GNOME_DIR/extensions-disabled.list"; do
        [[ -f "$list_file" ]] || continue
        while IFS= read -r ext; do
            [[ "$ext" =~ ^#.*$ || -z "$ext" ]] && continue
            install_extension "$ext" || failed+=("$ext")
        done < "$list_file"
    done

    # ——— Step 2: Load dconf settings ———
    echo ""
    echo "[2/4] Loading dconf settings..."

    declare -A DCONF_MAP=(
        ["desktop.dconf"]="/org/gnome/desktop/"
        ["shell.dconf"]="/org/gnome/shell/"
        ["extensions.dconf"]="/org/gnome/shell/extensions/"
        ["terminal.dconf"]="/org/gnome/terminal/"
    )

    for file in desktop.dconf shell.dconf extensions.dconf terminal.dconf; do
        if [[ -f "$DCONF_DIR/$file" ]]; then
            dconf load "${DCONF_MAP[$file]}" < "$DCONF_DIR/$file"
            echo "  → Loaded $file"
        fi
    done

    # ——— Step 3: Enable/disable extensions ———
    echo ""
    echo "[3/4] Setting extension states..."

    if [[ -f "$GNOME_DIR/extensions-enabled.list" ]]; then
        while IFS= read -r ext; do
            [[ "$ext" =~ ^#.*$ || -z "$ext" ]] && continue
            gnome-extensions enable "$ext" 2>/dev/null \
                && echo "  → Enabled: $ext" \
                || echo "  ⚠  Could not enable: $ext"
        done < "$GNOME_DIR/extensions-enabled.list"
    fi

    if [[ -f "$GNOME_DIR/extensions-disabled.list" ]]; then
        while IFS= read -r ext; do
            [[ "$ext" =~ ^#.*$ || -z "$ext" ]] && continue
            gnome-extensions disable "$ext" 2>/dev/null \
                && echo "  → Disabled: $ext" \
                || echo "  ⚠  Could not disable: $ext"
        done < "$GNOME_DIR/extensions-disabled.list"
    fi

    # ——— Step 4: Keybindings ———
    echo ""
    echo "[4/4] Importing keybindings..."

    if [[ -f "$SCRIPT_DIR/gnome_keybindings.pl" ]] && [[ -f "$GNOME_DIR/gsettings.csv" ]]; then
        perl "$SCRIPT_DIR/gnome_keybindings.pl" -i "$GNOME_DIR/gsettings.csv"
        echo "  → Keybindings imported"
    else
        echo "  ⚠  Keybindings script or data not found, skipping"
    fi

    # ——— Summary ———
    echo ""
    echo "=== Restore complete ==="

    if [[ ${#failed[@]} -gt 0 ]]; then
        echo ""
        echo "⚠  These extensions need manual install:"
        for ext in "${failed[@]}"; do
            echo "  - $ext  →  https://extensions.gnome.org"
        done
    fi

    echo ""
    echo "Log out and back in for all changes to take effect."
}

# ——————————————————————————————————————————————————
# Main
# ——————————————————————————————————————————————————
[[ $# -lt 1 ]] && usage

case "$1" in
    backup)  do_backup ;;
    restore) do_restore ;;
    *) usage ;;
esac
