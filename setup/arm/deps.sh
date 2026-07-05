#!/bin/bash
############################
# setup/arm/deps.sh
# Detects the available package manager and runs the right deps script.
############################

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v pkg >/dev/null; then
    bash "$DIR/deps-pkg.sh"
elif command -v apk >/dev/null; then
    bash "$DIR/deps-apk.sh"
elif command -v apt-get >/dev/null; then
    bash "$DIR/deps-apt.sh"
else
    echo "No supported package manager found (pkg, apk, or apt-get)" >&2
    exit 1
fi
