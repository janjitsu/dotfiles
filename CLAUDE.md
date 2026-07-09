# CLAUDE.md

Project context for AI assistants working on this codebase.

## What This Is

Personal dotfiles repo for a GNOME desktop running on Ubuntu (primary) and Fedora (secondary). Automates full system setup from a fresh install via a single bootstrap command.

## Architecture

### Setup Flow

`bootstrap.sh` downloads the repo as a tarball (no git needed), then runs `setup.sh` which orchestrates:

1. **Distro packages** — `setup/ubuntu.sh` or `setup/fedora.sh` (auto-detected)
2. **Desktop-only distro packages** — `setup/ubuntu/desktop/*.sh` or `setup/fedora/desktop/*.sh`, skipped when `--no-desktop` is passed
3. **Symlinks** — `setup/symlinks.sh` creates all config symlinks
4. **Common tools** — `setup/common.sh` (nvim, go, node, kanata)
5. **Desktop apps** — `setup/apps.sh` (IntelliJ, Postman, VMPK), also skipped by `--no-desktop`
6. **GNOME restore** — `backup/gnome.sh restore`

`setup.sh` parses `--no-desktop` and exports `NO_DESKTOP`; `ubuntu.sh`/`fedora.sh` read it (defaulting to `false` via `${NO_DESKTOP:-false}`) to decide whether to run the `desktop/` subfolder and `apps.sh`.

### Orchestrator Pattern

`setup/ubuntu.sh`, `setup/fedora.sh`, `setup/common.sh`, and `setup/apps.sh` are generic runners — they glob `*.sh` in their respective folders. To add a new tool, drop a script in the folder. Within `setup/ubuntu/` and `setup/fedora/`, packages that need a display/GUI (GNOME apps, media players, tray utilities, etc.) go in the `desktop/` subfolder so `--no-desktop` skips them; CLI/headless-safe tools (and anything another common script depends on, like `pip.sh`) stay in the folder root and always run.

### Config Management

- **Symlinked configs**: htop, PulseEffects, VMPK, touchegg, neovim, and all home dotfiles (bashrc, vimrc, tmux.conf, etc.) are symlinked so edits go straight to the repo.
- **dconf dump/load**: GNOME settings (extensions, shell, desktop, terminal) are backed up as text dumps and restored via `dconf load`. They cannot be symlinked because dconf uses a binary database.
- **Desktop file templates**: `.desktop` files use `%USER%` placeholders, resolved via `sed` at install time.

### Backup Scripts

Located in `backup/`, using subcommand pattern (`backup` / `restore`):
- `gnome.sh` — extensions list, dconf settings, keybindings (via Perl script)
- `sticky-notes.sh` — zips sensitive data to gitignored `tmp/`

### Distro Support

Ubuntu and Fedora are both supported. Each has its own folder under `setup/` with equivalent scripts. Anything that branches on package manager (e.g. `docker.sh`, `ctags.sh`) belongs in `setup/ubuntu/` and `setup/fedora/` as separate per-distro scripts, not in `setup/common/` — `common/` is reserved for scripts that run the same commands regardless of distro. Key package name differences:
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

- **Commit messages**: `type: description` — single-line subject, no body. `type` is one of `feat`, `fix`, or `chore` (no other types are used in this repo). Description is a short imperative phrase, lowercase after the colon (e.g. `fix: check for apk first`, `feat: add setup deps for alpine`, `chore: update readme`). No trailing period.
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
