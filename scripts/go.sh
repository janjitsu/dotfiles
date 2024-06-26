#!/bin/bash

wget -qO- "https://dl.google.com/go/$(curl https://go.dev/VERSION?m=text).linux-amd64.tar.gz" | \
tar xvz

mv go ~/.go

# go tools
#
# glow markdown cli reader
go install github.com/charmbracelet/glow@latest

# fzf
go install github.com/junegunn/fzf@latest
