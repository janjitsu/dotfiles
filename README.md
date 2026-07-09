# Dotfiles

Personal dotfiles and system setup automation. One command sets up a fresh machine end-to-end: packages, configs, desktop apps, GNOME extensions, and keybindings — exactly how it was before.

## Supported platforms

- **Ubuntu** (primary) and **Fedora** (secondary) — full desktop setup on GNOME
- **ARM** (Termux / proot-distro on Android) — lean CLI-only setup: dotfiles + Neovim + Tmux, no desktop

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/janjitsu/dotfiles/main/bootstrap.sh | bash
```

No git required — the bootstrap downloads the repo as a tarball, runs setup, then initializes git for future updates. The distro/architecture is auto-detected; nothing to choose.

## Options

| Flag | Effect |
|------|--------|
| `--no-desktop` | Skip GUI-only packages and desktop apps (servers, headless boxes, VMs) |

```bash
curl -fsSL https://raw.githubusercontent.com/janjitsu/dotfiles/main/bootstrap.sh | bash -s -- --no-desktop
```
