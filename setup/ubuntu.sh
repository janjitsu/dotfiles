#!/bin/bash
############################
# setup/ubuntu.sh
# Run all setup scripts in setup/ubuntu/
############################

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ubuntu"

echo "=== Ubuntu Setup ==="
for script in "$DIR"/*.sh; do
    echo "→ Running $(basename "$script")..."
    bash "$script"
done
echo "=== Ubuntu setup complete ==="
