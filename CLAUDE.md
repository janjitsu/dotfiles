# CLAUDE.md

Project context for AI assistants working on this codebase.

## What This Is

Personal dotfiles repo for a GNOME desktop running on Ubuntu (primary) and Fedora (secondary), plus a lean CLI-only setup for ARM (Termux / proot-distro on Android). Automates full system setup from a fresh install via a single bootstrap command.

## Architecture

### Setup Flow

`bootstrap.sh` downloads the repo as a tarball (no git needed), then runs `setup.sh`, which branches on `uname -m`: `aarch64` runs `setup/arm.sh` (lean path); everything else detects `apt-get`/`dnf` and runs the Ubuntu/Fedora flow:

1. **Distro packages** — `setup/ubuntu.sh` or `setup/fedora.sh` (auto-detected)
2. **Desktop-only distro packages** — `setup/ubuntu/desktop/*.sh` or `setup/fedora/desktop/*.sh`, skipped when `--no-desktop` is passed
3. **Symlinks** — `setup/symlinks.sh` creates all config symlinks
4. **Common tools** — `setup/common.sh` (nvim, go, node, kanata)
5. **Desktop apps** — `setup/apps.sh` (IntelliJ, Postman, VMPK, Ardour), also skipped by `--no-desktop`
6. **GNOME restore** — `backup/gnome.sh restore`

`setup.sh` parses `--no-desktop` and exports `NO_DESKTOP`; `ubuntu.sh`/`fedora.sh` read it (defaulting to `false` via `${NO_DESKTOP:-false}`) to decide whether to run the `desktop/` subfolder and `apps.sh`.

**ARM (Termux / proot-distro)**: `aarch64` means an Android device — either native Termux or a proot-distro container (e.g. a slim Ubuntu or Alpine server running inside Termux). Scope is dotfiles + Neovim + Tmux only, no desktop apps, fonts, or GNOME:

```
setup/arm.sh
  ├── setup/arm/deps.sh        # detects package manager, delegates below
  │     ├── deps-apk.sh        # Alpine (proot-distro), via apk
  │     ├── deps-apt.sh        # Ubuntu (proot-distro), via apt-get
  │     └── deps-pkg.sh        # native Termux, via pkg
  └── setup/arm/symlinks.sh    # home dotfiles + nvim only
```

### Orchestrator Pattern

`setup/ubuntu.sh`, `setup/fedora.sh`, `setup/common.sh`, and `setup/apps.sh` are generic runners — they glob `*.sh` in their respective folders. To add a new tool, drop a script in the folder. Within `setup/ubuntu/` and `setup/fedora/`, packages that need a display/GUI (GNOME apps, media players, tray utilities, etc.) go in the `desktop/` subfolder so `--no-desktop` skips them; CLI/headless-safe tools (and anything another common script depends on, like `pip.sh`) stay in the folder root and always run. `00-base.sh` in each is prefixed to always run first in the glob order — it does `apt update`/`dnf update` plus core CLI tools, and other scripts assume that already happened (e.g. `git` being available).

### Directory Structure

```
dotfiles/
├── setup.sh                 # Main entry point
├── bootstrap.sh              # Curl-friendly bootstrapper
├── setup/
│   ├── ubuntu.sh / fedora.sh / arm.sh   # Per-platform orchestrators
│   ├── common.sh             # Runs all setup/common/*.sh
│   ├── apps.sh                # Runs all setup/apps/*.sh
│   ├── symlinks.sh           # All symlink operations
│   ├── ubuntu/, fedora/       # Per-tool install scripts (+ desktop/ subfolder, GUI-only)
│   ├── arm/                   # deps (apk/apt/pkg) + symlinks for aarch64
│   ├── common/                 # Distro-agnostic (nvim, go, node, kanata, docker via common/php82-docker.sh)
│   └── apps/                  # Desktop apps (idea, postman, vmpk, ardour)
├── test/                      # Docker-based end-to-end setup tests
├── backup/                    # backup.sh, restore.sh, gnome.sh, sticky-notes.sh
├── gnome/                     # Committed GNOME backup artifacts (extensions list, dconf dumps, keybindings)
├── scripts/                   # Standalone utility scripts, not part of setup (see below)
│   # Config dirs symlinked to ~/.config/: htop/, pulseeffects/, vmpk/, ardour/, solaar/, nvim/
│   # Dotfiles symlinked to ~/: bashrc, zshrc, shellrc, vimrc, ideavimrc, tmux.conf, tmux/,
│   #   gitconfig, gitignore, touchegg.conf, kanata.kbd
└── tmp/                       # Gitignored temp files (backup zips, etc.)
```

### Config Management

- **Symlinked configs**: htop, PulseEffects, VMPK, touchegg, neovim, and all home dotfiles (bashrc, vimrc, tmux.conf, etc.) are symlinked so edits go straight to the repo.
- **dconf dump/load**: GNOME settings (extensions, shell, desktop, terminal) are backed up as text dumps and restored via `dconf load`. They cannot be symlinked because dconf uses a binary database.
- **Desktop file templates**: `.desktop` files use `%USER%` placeholders, resolved via `sed` at install time.

### Design Principles

- **Drop a script, it runs.** Orchestrators glob `*.sh` in their folder — no registration step needed.
- **Symlink everything possible.** Config changes go straight to the repo.
- **Sensitive data stays out.** Backups go to `tmp/` (gitignored).
- **ARM gets a lean subset, not a smaller version of the same thing.** `setup/arm.sh` only symlinks dotfiles + nvim and installs CLI deps — no desktop apps, fonts, or GNOME steps ever run there.

### Shell Architecture

```
~/.bashrc  →  dotfiles/bashrc  →  sources shellrc
~/.zshrc   →  dotfiles/zshrc   →  sources shellrc
```

**`shellrc`** — shared config for both bash and zsh: sources `~/.bash_aliases` and `~/.bash_local`; sets keyboard repeat rate for vim; Logitech K400/K380 mappings; GNOME focus-follows-mouse (`sloppy`); PATH for nvim/Go/Python/Ruby(rbenv)/Node(n)/Cargo/Android SDK; auto-starts tmux + neofetch; fzf zsh history (`Ctrl+R`); Calibre dark mode.

**`bash_aliases`** — sources modular files from `aliases/` (`docker.bash_aliases`: `dockerip`; `functions.bash_aliases`: `alert`, `prettyjson`, `diskfree`), plus `~/.bash_local` for machine-specific/private config (gitignored). Common aliases: `gst`/`ga`/`gci`/`gc`/`gd`/`glg` (git shortcuts), `vim` → `nvim`, `z` → reload zshrc, `k` → `kubectl`.

### Backup Scripts

Located in `backup/`, using subcommand pattern (`backup` / `restore`):
- `backup.sh` / `restore.sh` — unified pre-reinstall backup/restore: SSH keys, AWS/Docker/mkcert/npm/GNOME-keyring credentials, `gitconfig_local`, and GNOME settings. Zips to gitignored `tmp/`. Restore is deliberately **not** part of `setup.sh` (not all systems run GNOME or need the same credentials) — run manually after setup completes.
- `gnome.sh` — extensions list, dconf settings, keybindings (via Perl script `gnome_keybindings.pl`)
- `sticky-notes.sh` — zips sensitive data to gitignored `tmp/`

### Desktop Apps

`setup/apps/*.sh`, downloaded directly (not via package manager) to `~/apps/<appname>/`: `idea.sh` (IntelliJ), `postman.sh`, `vmpk.sh` (+ symlinked config/mappings). `ardour.sh` requires a manually-downloaded `.run` file passed as `$1` (Ardour's binaries are donation-gated) — it exits 1 with instructions if no file is given; `setup/apps.sh` treats this as non-fatal and continues installing the rest.

### Testing

`test/test.sh {ubuntu|fedora|arm-alpine|arm-ubuntu|all}` runs the full setup (desktop + apps included) inside a disposable, systemd-enabled Docker container built from `test/Dockerfile.ubuntu`/`test/Dockerfile.fedora`. Requires `--privileged --cgroupns=host` — the `cgroupns=host` part matters whenever the Docker host itself runs inside a container (CI, sandboxed dev environments), otherwise systemd fails to boot (exit 255, no log output). `apps/ardour.sh` is expected to fail there (see Desktop Apps above); the test's actual pass/fail signal comes from `setup.sh`'s exit code, which still fails fast on distro/desktop packages and common tools.

`arm-alpine`/`arm-ubuntu` run `setup/arm.sh` directly (not `setup.sh`) against plain, non-privileged containers — no aarch64 emulation is assumed available, and `setup/arm.sh` never touches systemd, so this only exercises package-manager detection, dependency installs, and symlinks, not real ARM binaries. The Termux (`pkg`) variant (`setup/arm/deps-pkg.sh`) can't be tested this way since `pkg` only exists inside real Termux.

### Distro Support

Ubuntu and Fedora are both supported. Each has its own folder under `setup/` with equivalent scripts. Anything that branches on package manager (e.g. `docker.sh`, `ctags.sh`) belongs in `setup/ubuntu/` and `setup/fedora/` as separate per-distro scripts, not in `setup/common/` — `common/` is reserved for scripts that run the same commands regardless of distro. Key package name differences:
- `ack-grep` (Ubuntu) → `ack` (Fedora)
- `silversearcher-ag` → `the_silver_searcher`
- `exuberant-ctags` → `ctags`
- `gnome-shell-extension-manager` → `gnome-extensions-app`
- `pulseeffects` → `easyeffects` (Fedora uses PipeWire)
- OBS on Fedora needs RPM Fusion for ffmpeg
- Fedora 41+ ships DNF5, which changed `dnf config-manager --add-repo <url>` to `dnf config-manager addrepo --from-repofile=<url>`
- Debian/Ubuntu enforce PEP 668 (`externally-managed-environment`) on system `pip install`; needs `--break-system-packages`. Fedora doesn't enforce this.

## Utility Scripts

`scripts/` — standalone, not part of setup: `disk-health.sh` (SMART report, auto-installs `smartmontools`), `fix-nvme-sleep.sh` (GRUB fix for NVMe sleep/wake hangs), `pactl_switch_sink.sh` (cycle audio outputs), `share_folder_smb.sh` (Samba share setup), `thirds.sh` (window snapping), `generate_cpf.sh`/`generate_cnpj_bugado.sh` (Brazilian document generators), `enable-hibernate.sh` (WIP).

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
- systemd for services (touchegg, kanata, docker)

## Roadmap / Known Gaps

- Save/restore vim sessions with tmux; system copy-paste with tmux
- Considering a refactor to Ansible (roles: base/desktop/gnome/dev-tools/apps, `ansible-pull` instead of `curl | bash`)
- Promote `scripts/*.sh` to first-class CLI commands on `$PATH` with `--help`
- Kanata: install binary to `/usr/local/bin` instead of `~/Programs`
- Clean up leftover `scripts/docker/php.sh` (superseded by `setup/common/php82-docker.sh`)
- No `setup/desktop/cemu.sh` yet (desktop file exists, no setup script)
- No `--dry-run` flag on `setup.sh`
