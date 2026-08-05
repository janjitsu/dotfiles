#!/bin/bash
############################
# setup/arch/optional/ardour.sh
# Delegates to the existing generic installer (donation-gated manual
# .run file) instead of duplicating that logic.
############################

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$DIR/../../apps/ardour.sh" "$@"
