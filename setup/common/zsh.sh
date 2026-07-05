#!/bin/bash
set -euo pipefail

chsh -s /usr/bin/zsh "$USER"
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
