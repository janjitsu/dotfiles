#!/bin/bash
############################
# setup/ubuntu/ctags.sh
# Build universal-ctags from source (apt build deps)
############################

sudo apt install -y \
    gcc make \
    pkg-config autoconf automake \
    python3-docutils \
    libseccomp-dev \
    libjansson-dev \
    libyaml-dev \
    libxml2-dev

git clone https://github.com/universal-ctags/ctags.git
cd ctags
./autogen.sh
./configure
make
sudo make install
cd ..
sudo rm -r ctags/
