#!/bin/bash
############################
# setup.sh
# Detects the environment and delegates to the appropriate setup orchestrator.
############################

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ——— Parse parameters ———
# Parsed once here and exported so distro orchestrators just read the
# variable instead of each re-parsing $@.
NO_DESKTOP=false
for arg in "$@"; do
    case "$arg" in
        --no-desktop) NO_DESKTOP=true ;;
    esac
done
export NO_DESKTOP

# aarch64 means we're on an Android device — either native Termux or a
# proot-distro container (e.g. slim Ubuntu server). Both get the lean setup:
# no desktop apps, no GNOME, no GUI fonts.
if [[ "$(uname -m)" == aarch64 ]]; then
    bash "$DIR/setup/arm.sh"
elif command -v apt-get >/dev/null; then
    bash "$DIR/setup/ubuntu.sh"
elif command -v dnf >/dev/null; then
    bash "$DIR/setup/fedora.sh"
fi
