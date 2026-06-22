#!/bin/bash
############################
# setup/common.sh
# Run all setup scripts in setup/common/
############################

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common"

echo "=== Common Setup ==="
for script in "$DIR"/*.sh; do
    echo "→ Running $(basename "$script")..."
    bash "$script"
done
echo "=== Common setup complete ==="
