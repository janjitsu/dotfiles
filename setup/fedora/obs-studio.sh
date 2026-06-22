#!/bin/bash
# RPM Fusion is needed for ffmpeg on Fedora
sudo dnf install -y \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
    2>/dev/null || true

sudo dnf install -y ffmpeg vlc obs-studio
