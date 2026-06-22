#!/bin/bash
############################
# setup/fedora.sh
# Run all setup scripts in setup/fedora/
############################

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/fedora"

echo "=== Fedora Setup ==="
for script in "$DIR"/*.sh; do
    echo "→ Running $(basename "$script")..."
    bash "$script"
done
echo "=== Fedora setup complete ==="
