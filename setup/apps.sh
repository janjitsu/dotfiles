#!/bin/bash
############################
# setup/apps.sh
# Run all setup scripts in setup/desktop/
############################

set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/apps"

echo "=== Desktop Apps Setup ==="
failed=()
for script in "$DIR"/*.sh; do
    echo "→ Running $(basename "$script")..."
    if ! bash "$script"; then
        echo "  ⚠ $(basename "$script") failed — continuing with the rest"
        failed+=("$(basename "$script")")
    fi
done

if [[ ${#failed[@]} -gt 0 ]]; then
    echo ""
    echo "⚠ Some apps did not install: ${failed[*]}"
    echo "  (ardour.sh failing is expected unless you passed a downloaded .run file)"
fi
echo "=== Desktop apps setup complete ==="
