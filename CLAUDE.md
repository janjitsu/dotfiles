# CLAUDE.md

Project context for AI assistants working on this codebase.

## What This Is

Personal dotfiles repo for a GNOME desktop running on Ubuntu (primary) and Fedora (secondary). Automates full system setup from a fresh install via a single bootstrap command.

## Architecture

### Setup Flow

`bootstrap.sh` downloads the repo as a tarball (no git needed), then runs `setup.sh` which orchestrates:

1. **Distro packages** — `setup/ubuntu.sh` or `setup/fedora.sh` (auto-detected)
2. **Symlinks** — `setup/symlinks.sh` creates all config symlinks
3. **Common tools** — `setup/common.sh` (nvim, go, docker, node, kanata)
4. **Desktop apps** — `setup/apps.sh` (IntelliJ, Postman, VMPK)
5. **GNOME restore** — `backup/gnome.sh restore`

### Orchestrator Pattern

`setup/ubuntu.sh`, `setup/fedora.sh`, `setup/common.sh`, and `setup/apps.sh` are generic runners — they glob `*.sh` in their respective folders. To add a new tool, drop a script in the folder.

### Config Management

- **Symlinked configs**: htop, PulseEffects, VMPK, touchegg, neovim, and all home dotfiles (bashrc, vimrc, tmux.conf, etc.) are symlinked so edits go straight to the repo.
- **dconf dump/load**: GNOME settings (extensions, shell, desktop, terminal) are backed up as text dumps and restored via `dconf load`. They cannot be symlinked because dconf uses a binary database.
- **Desktop file templates**: `.desktop` files use `%USER%` placeholders, resolved via `sed` at install time.

### Backup Scripts

Located in `backup/`, using subcommand pattern (`backup` / `restore`):
- `gnome.sh` — extensions list, dconf settings, keybindings (via Perl script)
- `sticky-notes.sh` — zips sensitive data to gitignored `tmp/`

### Distro Support

Ubuntu and Fedora are both supported. Each has its own folder under `setup/` with equivalent scripts. Key package name differences:
- `ack-grep` (Ubuntu) → `ack` (Fedora)
- `silversearcher-ag` → `the_silver_searcher`
- `exuberant-ctags` → `ctags`
- `gnome-shell-extension-manager` → `gnome-extensions-app`
- `pulseeffects` → `easyeffects` (Fedora uses PipeWire)
- OBS on Fedora needs RPM Fusion for ffmpeg

## Key Files

| File | Purpose |
|------|---------|
| `bootstrap.sh` | Curl-friendly entry point for fresh machines |
| `setup.sh` | Main orchestrator |
| `setup/symlinks.sh` | All symlink operations in one place |
| `backup/gnome.sh` | GNOME backup/restore (extensions, dconf, keybindings) |
| `backup/gnome_keybindings.pl` | Perl script for gsettings keybinding I/O |
| `setup/apps/*.desktop` | Templates with `%USER%` placeholder |

## Conventions

- Scripts should be idempotent (safe to re-run)
- Existing configs are backed up to `~/dotfiles_old/` before symlinking
- Sensitive data goes to `tmp/` which is gitignored
- Ubuntu system GNOME extensions are filtered out of backups: `ding@`, `ubuntu-appindicators@`, `ubuntu-dock@`
- Desktop apps are installed to `~/apps/<appname>/`
- The `scripts/` folder contains standalone utility scripts (not part of setup)

## Tech Stack

- Bash scripts throughout
- Perl for keybinding management (`gnome_keybindings.pl`)
- Python3 used inline for JSON parsing (JetBrains API, SourceForge API)
- dconf CLI for GNOME settings
- systemd for services (touchegg, kanata)
