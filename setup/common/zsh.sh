#!/bin/bash
set -euo pipefail

chsh -s /usr/bin/zsh "$USER"
# --unattended: skip oh-my-zsh's own (redundant) shell-change prompt, and
# don't drop into a new zsh shell at the end — that would hang unattended
# automation forever since nothing would return control to this script
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh -s -- --unattended
