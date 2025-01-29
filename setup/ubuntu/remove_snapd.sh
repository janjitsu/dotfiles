#!/bin/bash
snap list
snap remove firefox snap-store
sudo systemctl stop snapd
sudo apt remove --purge --assume-yes snapd gnome-software-plugin-snap
sudo rm -fr ~/snap/

