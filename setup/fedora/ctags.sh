#!/bin/bash
############################
# setup/fedora/ctags.sh
# Build universal-ctags from source (dnf build deps)
############################

sudo dnf install -y \
    gcc make \
    pkgconfig autoconf automake \
    python3-docutils \
    libseccomp-devel \
    jansson-devel \
    libyaml-devel \
    libxml2-devel

git clone https://github.com/universal-ctags/ctags.git
cd ctags
./autogen.sh
./configure
make
sudo make install
cd ..
sudo rm -r ctags/
