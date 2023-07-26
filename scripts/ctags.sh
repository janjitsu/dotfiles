#!/bin/bash

if command -v apt-get >/dev/null; then
    sudo apt install -y \
        gcc make \
        pkg-config autoconf automake \
        python3-docutils \
        libseccomp-dev \
        libjansson-dev \
        libyaml-dev \
        libxml2-dev
elif command -v yum >/dev/null; then
    sudo dnf install -y\
        gcc make \
        pkgconfig autoconf automake \
        python3-docutils \
        libseccomp-devel \
        jansson-devel \
        libyaml-devel \
        libxml2-devel
fi

git clone https://github.com/universal-ctags/ctags.git
cd ctags
./autogen.sh
./configure
make
sudo make install
cd ..
sudo rm -r ctags/
