#!/bin/bash
GOLANG_LATEST_STABLE_VERSION=$(curl "https://go.dev/dl/?mode=json" | grep -o 'go.*.linux-amd64.tar.gz' | head -n 1 | tr -d '\r\n' )
wget -qO- "https://dl.google.com/go/$GOLANG_LATEST_STABLE_VERSION" | \
tar xvz

mv go ~/.go

# go tools
#
# glow markdown cli reader
go install github.com/charmbracelet/glow@latest

# fzf - fuzzy finder
go install github.com/junegunn/fzf@latest

# logalize - colored logs
go install github.com/deponian/logalize@latest

