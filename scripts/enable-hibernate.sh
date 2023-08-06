#!/bin/bash

echo "Enable hibernate file..."

sudo cat <<'EOF' > /etc/polkit-1/localauthority/50-local.d/com.ubuntu.enable-hibernate.pkla
[Re-enable hibernate by default in upower]
Identity=unix-user:*
Action=org.freedesktop.upower.hibernate
ResultActive=yes

[Re-enable hibernate by default in logind]
Identity=unix-user:*
Action=org.freedesktop.login1.hibernate;org.freedesktop.login1.handle-hibernate-key;org.freedesktop.login1;org.freedesktop.login1.hibernate-multiple-sessions;org.freedesktop.login1.hibernate-ignore-inhibit
ResultActive=yes
EOF

sudo cat /etc/polkit-1/localauthority/50-local.d/com.ubuntu.enable-hibernate.pkla

echo "Getting swap partition UUID..."

SWAP_UUID=$(sudo blkid | grep swap | sed -e "s/^.* UUID=\"\([^ ]*\)\".*$/\1/")

echo $SWAP_UUID

echo "Writing resume config to grub..."

sudo sed -i s"/quiet splash.*\"/quiet splash resume=UID=$SWAP_UUID\"/" /etc/default/grub

cat test-grub

sudo update-grub
