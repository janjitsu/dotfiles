#!/bin/bash
set -euo pipefail

git clone https://github.com/powerline/fonts.git --depth=1
./fonts/install.sh
rm -rf fonts
