#!/bin/bash
# Install and configure Xfce alongside GNOME: packages, Greybird-dark +
# elementary-xfce icons, Iosevka Nerd Font, DPI 125 scale, panel layout, rofi,
# GNOME-like terminal bell sound, and a Super-based keybinding scheme.
# Idempotent: safe to re-run (xfconf-query -n creates or overwrites).

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

if [ "$EUID" -eq 0 ]; then
  echo "Error: run as your normal user, not root (sudo is called when needed)."
  exit 1
fi

echo "→ Installing Xfce"
sudo dnf group install -y xfce-desktop-environment
sudo dnf install -y xfce4-whiskermenu-plugin elementary-xfce-icon-theme \
  adwaita-icon-theme greybird-dark-theme greybird-xfwm4-theme rofi maim xclip ptyxis python3 libcanberra-gtk3 \
  sound-theme-freedesktop gnome-calendar

echo "→ Iosevka Nerd Font"
bash "$DIR/setup/common/nerd-font-iosevka.sh"

# xfconf-query needs a session bus; skip gracefully if there is none.
if ! command -v xfconf-query >/dev/null || [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
  echo "→ No session bus; re-run this script from a desktop session to apply settings."
  exit 0
fi

xset_() { # xset_ <channel> <property> <type> <value>   (create/overwrite)
  xfconf-query -c "$1" -n -t "$3" -p "$2" -s "$4"
}
bind() { # bind <accelerator> <xfwm4 action>
  xset_ xfce4-keyboard-shortcuts "/xfwm4/custom/$1" string "$2"
}
cmd() { # cmd <accelerator> <command>
  xset_ xfce4-keyboard-shortcuts "/commands/custom/$1" string "$2"
}

# ——— Appearance ———
echo "→ Applying appearance (Greybird-dark, elementary-xfce, Iosevka, DPI 125)"
xset_ xsettings /Net/ThemeName string "Greybird-dark"
xset_ xsettings /Net/IconThemeName string "elementary-xfce-dark"
xset_ xsettings /Gtk/FontName string "Iosevka Nerd Font Bold 12"
xset_ xsettings /Gtk/MonospaceFontName string "Iosevka Nerd Font 12"
# X11 has no fractional window scale, so scale via DPI (96 * 1.30 = 125) and
# keep the integer window scale at 1.
xset_ xsettings /Xft/DPI int 125
xset_ xsettings /Xfce/LastCustomDPI int 125
xset_ xsettings /Gdk/WindowScalingFactor int 1
xset_ xfwm4 /general/title_font string "Iosevka Nerd Font Oblique 12"
xset_ xfwm4 /general/borderless_maximize bool true
xset_ xsettings /Gtk/CursorThemeSize int 72
# Focus follows the mouse without raising (like GNOME's sloppy focus); no workspace wrap-around.
xset_ xfwm4 /general/click_to_focus bool false
xset_ xfwm4 /general/raise_on_focus bool false
xset_ xfwm4 /general/wrap_workspaces bool false
xset_ xfce4-desktop /desktop-icons/style int 0
gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true

# ——— Keyboard repeat (matches shellrc: delay 200, rate 35) ———
xset_ keyboards /Default/KeyRepeat/Delay int 200
xset_ keyboards /Default/KeyRepeat/Rate int 35

# ——— Terminal: Ptyxis (same as under GNOME) ———
mkdir -p ~/.config/xfce4
if grep -q '^TerminalEmulator=' ~/.config/xfce4/helpers.rc 2>/dev/null; then
  sed -i 's/^TerminalEmulator=.*/TerminalEmulator=ptyxis/' ~/.config/xfce4/helpers.rc
else
  echo "TerminalEmulator=ptyxis" >> ~/.config/xfce4/helpers.rc
fi

# ——— Terminal bell: drum sample (sounds/drum.wav) instead of the raw X beep ———
echo "→ Terminal bell sound"
xset_ xsettings /Net/EnableEventSounds bool true
xset_ xsettings /Net/EnableInputFeedbackSounds bool true
xset_ xsettings /Net/SoundThemeName string "freedesktop"
mkdir -p ~/.local/bin ~/.config/autostart
ln -sfn "$DIR/scripts/xkb-bell-sound" ~/.local/bin/xkb-bell-sound
ln -sfn "$DIR/scripts/snip" ~/.local/bin/snip
ln -sfn "$DIR/scripts/tile-thirds" ~/.local/bin/tile-thirds
cat > ~/.config/autostart/xkb-bell-sound.desktop <<EOF
[Desktop Entry]
Type=Application
Name=XKB bell sound
Comment=Play a drum hit instead of the X server beep
Exec=$HOME/.local/bin/xkb-bell-sound
OnlyShowIn=XFCE;
EOF

# ——— Workspaces: five, named 1-5 ———
xfconf-query -c xfwm4 -n -t int -p /general/workspace_count -s 5
xfconf-query -c xfwm4 -r -p /general/workspace_names 2>/dev/null || true
xfconf-query -c xfwm4 -n -a -p /general/workspace_names \
  -t string -s 1 -t string -s 2 -t string -s 3 -t string -s 4 -t string -s 5

# ——— Panels: load the hand-made layout snapshot from xfce/ ———
echo "→ Loading panel layout (xfce/)"
CFG=~/.config/xfce4
XML="$CFG/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
mkdir -p "$CFG/xfconf/xfce-perchannel-xml" "$CFG/panel" ~/dotfiles_old
# Keep whatever panel config exists, once per run, before replacing it.
[ -f "$XML" ] && cp -f "$XML" ~/dotfiles_old/xfce4-panel.xml.bak
# Replace the files while the panel and xfconfd are stopped, so xfconfd re-reads them.
xfce4-panel -q >/dev/null 2>&1 || true
pkill -x xfconfd 2>/dev/null || true
sleep 1
sed "s#%HOME%#$HOME#g" "$DIR/xfce/xfce4-panel.xml" > "$XML"
cp -f "$DIR/xfce/panel/datetime-16.rc" "$CFG/panel/"
for d in "$DIR"/xfce/panel/launcher-*; do
  n="$(basename "$d")"
  rm -rf "$CFG/panel/$n"
  mkdir -p "$CFG/panel/$n"
  for f in "$d"/*.desktop; do
    sed "s#%HOME%#$HOME#g" "$f" > "$CFG/panel/$n/$(basename "$f")"
  done
done

# The snapshot has no monitor names (a stale output-name hides the panels).
# Pin both panels to the largest connected output; re-runs heal it.
OUT="$(xrandr --query 2>/dev/null | awk '
  / connected/ { name=$1; for (i=1;i<=NF;i++) if ($i ~ /^[0-9]+x[0-9]+\+/) { split($i,g,/[x+]/); a=g[1]*g[2]; if (a>max) { max=a; best=name } } }
  END { print best }')"
(setsid xfce4-panel >/dev/null 2>&1 &)
sleep 3
if [ -n "$OUT" ]; then
  for n in 1 2; do
    xset_ xfce4-panel "/panels/panel-$n/output-name" string "$OUT"
  done
  echo "  panels pinned to $OUT"
fi

# ——— Keybindings (Super-based) ———
echo "→ Applying keybindings"
# Launchers / apps
cmd "<Super>Return" "ptyxis --new-window"
cmd "<Super>d"      "rofi -show drun"
cmd "<Super>e"      "thunar"
cmd "<Super>s"      "snip"
cmd "<Super>r"      "xfce4-appfinder"     # full window like the dock button (default is the collapsed -c bar)
cmd "<Super>b"      "rofi -show window"   # window switcher
# Tiling (tile-thirds: columns on landscape monitors, rows on portrait ones)
cmd "<Alt><Super>h"     "tile-thirds first"
cmd "<Alt><Super>j"     "tile-thirds second"
cmd "<Alt><Super>l"     "tile-thirds third"
cmd "<Alt><Super>y"     "tile-thirds first2"
cmd "<Alt><Super>o"     "tile-thirds last2"
cmd "<Alt><Super>Left"  "tile-thirds half-a"
cmd "<Alt><Super>Right" "tile-thirds half-b"
cmd "<Alt><Super>Up"    "tile-thirds full"
# Windows
bind "<Super>q" close_window_key
bind "<Super>f" maximize_window_key
# Workspaces: Super+1..5 go to, Super+Shift+1..5 move the window there
for n in 1 2 3 4 5; do
  bind "<Super>$n"          "workspace_${n}_key"
  bind "<Super><Shift>$n"   "move_window_workspace_${n}_key"
done
# Previous / next workspace
bind "<Super>h" left_workspace_key
bind "<Super>l" right_workspace_key
xfconf-query -c xfce4-keyboard-shortcuts -r -p "/xfwm4/custom/<Super>u" 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -r -p "/commands/custom/F13" 2>/dev/null || true
bind "<Super>Home" workspace_1_key
bind "<Super>End"  workspace_last_key
# Move window
bind "<Primary><Shift><Alt>Left"  move_window_left_workspace_key
bind "<Primary><Shift><Alt>Right" move_window_right_workspace_key
bind "<Primary><Shift><Alt>Up"    move_window_up_workspace_key
bind "<Primary><Shift><Alt>Down"  move_window_down_workspace_key
bind "<Super><Shift>Page_Up"      move_window_up_workspace_key
bind "<Super><Shift>Page_Down"    move_window_down_workspace_key
bind "<Super><Shift>Home"         move_window_workspace_1_key
bind "<Super><Shift>End"          move_window_last_workspace_key

# ——— Lock screen: Ctrl+Super+L instead of Super+L (Super+L is now next workspace) ———
xset_ xfce4-keyboard-shortcuts "/commands/custom/<Super>l" string ""
xset_ xfce4-keyboard-shortcuts "/commands/custom/<Primary><Super>l" string "xflock4"

echo "→ Done. Pick 'Xfce Session' on the login screen (log out/in once for everything to apply)."
