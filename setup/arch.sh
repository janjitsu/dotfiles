#!/bin/bash
############################
# setup/arch.sh
# Arch/CachyOS setup orchestrator — CLI/dev-tools-only base (this distro's
# target is a low-memory handheld) plus a customizable optional-apps list
# in place of the Ubuntu/Fedora desktop/ split.
############################

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NO_DESKTOP="${NO_DESKTOP:-false}"

echo "=== Arch/CachyOS Setup ==="

# ——— Distro packages (CLI/dev tools) ———
for script in "$DIR/arch"/*.sh; do
    echo "→ $(basename "$script")..."
    bash "$script"
done

# ——— Optional apps (customize via setup/arch/optional-apps.conf) ———
if [[ "$NO_DESKTOP" == true ]]; then
    echo "→ Skipping optional apps (--no-desktop)"
else
    echo "=== Optional Apps ==="
    CONF="$DIR/arch/optional-apps.conf"
    failed=()
    while IFS= read -r line || [[ -n "$line" ]]; do
        app="${line%%#*}"
        app="$(echo "$app" | xargs)"
        [[ -z "$app" ]] && continue

        script="$DIR/arch/optional/$app.sh"
        if [[ ! -f "$script" ]]; then
            echo "  ⚠ No script found for '$app' (expected $script) — skipping"
            continue
        fi

        echo "→ $app..."
        if ! bash "$script"; then
            echo "  ⚠ $app failed — continuing with the rest"
            failed+=("$app")
        fi
    done < "$CONF"

    if [[ ${#failed[@]} -gt 0 ]]; then
        echo ""
        echo "⚠ Some optional apps did not install: ${failed[*]}"
        echo "  (ardour failing is expected unless you passed a downloaded .run file)"
    fi
fi

# ——— Common steps (ordered) ———
bash "$DIR/common/zsh.sh"
bash "$DIR/common/fonts.sh"
bash "$DIR/arch/symlinks.sh"
bash "$DIR/common/nvim.sh"
bash "$DIR/common/go.sh"
bash "$DIR/common/node.sh"
bash "$DIR/common/kanata.sh"
bash "$DIR/common/php82-docker.sh"
bash "$DIR/common/vim-plugins.sh"
bash "$DIR/common/tmux-plugins.sh"

# bashrc's `[ -z "$PS1" ] && return` guard trips "unbound variable" under
# set -u when sourced non-interactively (PS1 usually isn't exported even in
# a real terminal) — relax -u just for this line
set +u
source ~/.bashrc
set -u
echo "=== Arch/CachyOS setup complete ==="
