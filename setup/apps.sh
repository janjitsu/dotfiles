#!/bin/bash
############################
# setup/apps.sh
# Run all setup scripts in setup/desktop/
############################

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/apps"

echo "=== Desktop Apps Setup ==="
for script in "$DIR"/*.sh; do
    echo "→ Running $(basename "$script")..."
    bash "$script"
done
echo "=== Desktop apps setup complete ==="
