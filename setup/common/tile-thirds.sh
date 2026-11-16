#!/bin/bash
# Register tile-thirds shortcuts as GNOME custom keybindings.
# Runs whenever gnome-shell is installed and a session bus exists (even from an Xfce
# session, so GNOME has them next time). Note: tile-thirds moves X11
# windows, so on GNOME Wayland it only affects XWayland apps (use the gTile
# extension there). Idempotent.
set -euo pipefail

if ! command -v gnome-shell >/dev/null || ! command -v gsettings >/dev/null \
   || [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
  echo "→ tile-thirds: no GNOME session, skipping keybindings"
  exit 0
fi

BASE=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings
SCHEMA=org.gnome.settings-daemon.plugins.media-keys
KEYS_SCHEMA="$SCHEMA.custom-keybinding"

# name | binding | argument
BINDINGS=(
  "first-third|<Super><Alt>h|first"
  "center-third|<Super><Alt>j|second"
  "last-third|<Super><Alt>l|third"
  "first-two-thirds|<Super><Alt>y|first2"
  "last-two-thirds|<Super><Alt>o|last2"
  "left-half|<Super><Alt>Left|half-a"
  "right-half|<Super><Alt>Right|half-b"
  "full|<Super><Alt>Up|full"
)

current="$(gsettings get "$SCHEMA" custom-keybindings)"
for entry in "${BINDINGS[@]}"; do
  IFS='|' read -r name binding arg <<<"$entry"
  path="$BASE/tile-thirds-$name/"
  gsettings set "$KEYS_SCHEMA:$path" name "Tile: $name"
  gsettings set "$KEYS_SCHEMA:$path" command "$HOME/.local/bin/tile-thirds $arg"
  gsettings set "$KEYS_SCHEMA:$path" binding "$binding"
  case "$current" in
    *"'$path'"*) ;;
    *) current="$(python3 - "$current" "$path" <<'PY'
import ast, sys
cur = sys.argv[1]
cur = cur[cur.index("["):] if "[" in cur else "[]"
lst = ast.literal_eval(cur)
lst.append(sys.argv[2])
print(lst)
PY
)" ;;
  esac
done
gsettings set "$SCHEMA" custom-keybindings "$current"
echo "→ tile-thirds GNOME keybindings registered"
