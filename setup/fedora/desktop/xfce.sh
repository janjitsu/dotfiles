#!/bin/bash
# Install and configure Xfce alongside GNOME: packages, Adwaita-dark +
# elementary-xfce icons, Iosevka Nerd Font, 1.15 scale, panel layout, rofi,
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
  adwaita-icon-theme rofi maim xclip ptyxis python3 libcanberra-gtk3 \
  sound-theme-freedesktop

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
echo "→ Applying appearance (Adwaita-dark, elementary-xfce, Iosevka, 1.15 scale)"
xset_ xsettings /Net/ThemeName string "Adwaita-dark"
xset_ xsettings /Net/IconThemeName string "elementary-xfce-dark"
xset_ xsettings /Gtk/FontName string "Iosevka Nerd Font Bold 12"
xset_ xsettings /Gtk/MonospaceFontName string "Iosevka Nerd Font 12"
# Same 1.15 as GNOME's text-scaling-factor: X11 has no fractional window scale,
# so scale via DPI (96 * 1.15 = 110) and keep the integer window scale at 1.
xset_ xsettings /Xft/DPI int 110
xset_ xsettings /Xfce/LastCustomDPI int 110
xset_ xsettings /Gdk/WindowScalingFactor int 1
xset_ xfwm4 /general/title_font string "Iosevka Nerd Font Oblique 12"
xset_ xfwm4 /general/borderless_maximize bool true
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

# ——— Terminal bell: freedesktop theme sound instead of the raw X beep ———
echo "→ Terminal bell sound"
xset_ xsettings /Net/EnableEventSounds bool true
xset_ xsettings /Net/EnableInputFeedbackSounds bool true
xset_ xsettings /Net/SoundThemeName string "freedesktop"
mkdir -p ~/.local/bin ~/.config/autostart
ln -sfn "$DIR/scripts/xkb-bell-sound" ~/.local/bin/xkb-bell-sound
ln -sfn "$DIR/scripts/snip" ~/.local/bin/snip
cat > ~/.config/autostart/xkb-bell-sound.desktop <<EOF
[Desktop Entry]
Type=Application
Name=XKB bell sound
Comment=Play the sound theme bell instead of the X server beep
Exec=$HOME/.local/bin/xkb-bell-sound
OnlyShowIn=XFCE;
EOF

# ——— Workspaces: five, named 1-5 ———
xfconf-query -c xfwm4 -n -t int -p /general/workspace_count -s 5
xfconf-query -c xfwm4 -r -p /general/workspace_names 2>/dev/null || true
xfconf-query -c xfwm4 -n -a -p /general/workspace_names \
  -t string -s 1 -t string -s 2 -t string -s 3 -t string -s 4 -t string -s 5

# ——— Panels ———
echo "→ Configuring panels"
# Both panels were pinned to a monitor name that no longer exists (HDMI-1), so
# neither drew. Pin them to the largest connected output instead; re-runs heal it.
OUT="$(xrandr --query 2>/dev/null | awk '
  / connected/ { name=$1; for (i=1;i<=NF;i++) if ($i ~ /^[0-9]+x[0-9]+\+/) { split($i,g,/[x+]/); a=g[1]*g[2]; if (a>max) { max=a; best=name } } }
  END { print best }')"
if [ -n "$OUT" ]; then
  for n in 1 2; do
    xfconf-query -c xfce4-panel -p "/panels/panel-$n/output-name" >/dev/null 2>&1 &&
      xfconf-query -c xfce4-panel -p "/panels/panel-$n/output-name" -s "$OUT"
  done
  echo "  panels pinned to $OUT"
fi

P=/plugins
LDIR=~/.config/xfce4/panel
mk_launcher() { # mk_launcher <plugin-id> <desktop file>
  mkdir -p "$LDIR/launcher-$1"
  cp -f "$2" "$LDIR/launcher-$1/"
  xset_ xfce4-panel "$P/plugin-$1" string launcher
  xfconf-query -c xfce4-panel -n -a -p "$P/plugin-$1/items" -t string -s "$(basename "$2")"
}
# panel-1 (top bar, video layout): whisker | pager | launchers | tasks | tray | clock
xset_ xfce4-panel "$P/plugin-1" string whiskermenu
xset_ xfce4-panel "$P/plugin-22" string separator
xset_ xfce4-panel "$P/plugin-22/style" uint 0
xset_ xfce4-panel "$P/plugin-4/miniature-view" bool false
xset_ xfce4-panel "$P/plugin-4/rows" uint 1
xset_ xfce4-panel "$P/plugin-5/style" uint 0
mk_launcher 23 /usr/share/applications/google-chrome-beta.desktop
mk_launcher 24 /usr/share/applications/org.gnome.Ptyxis.desktop
mk_launcher 25 /usr/share/applications/thunar.desktop
xset_ xfce4-panel "$P/plugin-8/digital-layout" uint 3
xset_ xfce4-panel "$P/plugin-8/digital-time-format" string "%H:%M"
xset_ xfce4-panel "$P/plugin-8/digital-time-font" string "Iosevka Nerd Font Propo Semi-Bold 12"
xfconf-query -c xfce4-panel -r -R -p "$P/plugin-9" 2>/dev/null || true
xfconf-query -c xfce4-panel -r -R -p "$P/plugin-10" 2>/dev/null || true
xfconf-query -c xfce4-panel -n -a -p /panels/panel-1/plugin-ids \
  -t int -s 1 -t int -s 22 -t int -s 4 -t int -s 5 -t int -s 23 -t int -s 24 -t int -s 25 \
  -t int -s 2 -t int -s 3 -t int -s 6 -t int -s 7 -t int -s 8
xset_ xfce4-panel /panels/panel-1/size uint 28
xset_ xfce4-panel /panels/panel-1/icon-size uint 22
# panel-2 is the autohide dock: left exactly as it was.
xfce4-panel -r >/dev/null 2>&1 || true

# ——— Keybindings (Super-based) ———
echo "→ Applying keybindings"
# Launchers / apps
cmd "<Super>Return" "ptyxis --new-window"
cmd "<Super>d"      "rofi -show drun"
cmd "<Super>e"      "thunar"
cmd "<Super>s"      "snip"
# Bare Super tap -> F13 (kanata.kbd tap-hold on lmet, fires on release) -> window switcher.
cmd "F13"           "rofi -show window"
cmd "<Super>b"      "rofi -show window"   # same switcher without kanata (e.g. external keyboards)
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
