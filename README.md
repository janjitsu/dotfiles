# Dotfiles

Personal dotfiles and system setup automation for Ubuntu and Fedora workstations running GNOME, plus a lean setup for ARM (Termux / proot-distro on Android).

One command on a fresh machine sets up everything — packages, configs, desktop apps, GNOME extensions, keybindings — exactly how it was before.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/janjitsu/dotfiles/main/bootstrap.sh | bash
```

No git required. The bootstrap downloads the repo as a tarball, runs setup, then initializes git for future updates.

Skip desktop apps (e.g. servers, headless boxes, VMs) with `--no-desktop`:

```bash
curl -fsSL https://raw.githubusercontent.com/janjitsu/dotfiles/main/bootstrap.sh | bash -s -- --no-desktop
```

## How It Works

### Bootstrap Flow

```
bootstrap.sh
  └── setup.sh
        ├── setup/arm.sh                             (aarch64: Termux / proot-distro — lean setup)
        ├── setup/ubuntu.sh  or  setup/fedora.sh    (distro packages)
        ├── setup/symlinks.sh                       (dotfile symlinks)
        ├── setup/common.sh                         (distro-agnostic tools)
        └── setup/apps.sh                           (desktop apps)
```

`setup.sh` branches on `uname -m`: `aarch64` runs `setup/arm.sh`; everything else detects `apt-get`/`dnf` and runs the Ubuntu/Fedora flow.

`setup.sh` also parses its own arguments once and exports them for the orchestrators it delegates to, so `ubuntu.sh`/`fedora.sh` just read the resulting variable instead of re-parsing `$@` themselves:

| Flag | Effect |
|------|--------|
| `--no-desktop` | Skips `setup/apps.sh` (no IntelliJ, Postman, VMPK, Ardour, …) — useful for servers/VMs |

#### ARM (Termux / proot-distro)

`aarch64` means an Android device — either native Termux or a proot-distro container (e.g. a slim Ubuntu or Alpine server running inside Termux). This gets a lean setup: dotfiles + Neovim + Tmux only, no desktop apps, fonts, or GNOME.

```
setup/arm.sh
  ├── setup/arm/deps.sh        # detects package manager, delegates below
  │     ├── deps-apk.sh        # Alpine (proot-distro), via apk
  │     ├── deps-apt.sh        # Ubuntu (proot-distro), via apt-get
  │     └── deps-pkg.sh        # native Termux, via pkg
  └── setup/arm/symlinks.sh    # home dotfiles + nvim only
```

### Directory Structure

```
dotfiles/
├── setup.sh                 # Main entry point
├── bootstrap.sh             # Curl-friendly bootstrapper
│
├── setup/
│   ├── ubuntu.sh            # Runs all setup/ubuntu/*.sh
│   ├── fedora.sh            # Runs all setup/fedora/*.sh
│   ├── arm.sh               # Lean orchestrator for aarch64 (Termux / proot-distro)
│   ├── common.sh            # Runs all setup/common/*.sh
│   ├── apps.sh              # Runs all setup/apps/*.sh
│   ├── symlinks.sh          # All symlink operations
│   ├── ubuntu/              # apt-based installs (one script per tool)
│   ├── fedora/              # dnf-based installs (mirrors ubuntu/)
│   ├── arm/                 # deps (apk/apt/pkg) + symlinks for aarch64
│   ├── common/              # Distro-agnostic (nvim, go, docker, node, kanata)
│   └── apps/                # Desktop apps (idea, postman, vmpk, ardour)
│
├── backup/
│   ├── backup.sh            # Unified pre-reinstall backup
│   ├── restore.sh           # Restore from backup zip
│   ├── gnome.sh             # GNOME backup/restore (extensions, dconf, keybindings)
│   └── sticky-notes.sh      # Sticky notes backup/restore
│
├── gnome/                   # GNOME backup artifacts (committed)
│   ├── extensions-*.list    # Extension lists for reinstall
│   ├── dconf/               # dconf dumps (shell, desktop, extensions, terminal, guake)
│   └── gsettings.csv        # Custom keybindings
│
├── scripts/                 # Utility scripts (see below)
│
│   # Config directories (symlinked to ~/.config/)
├── htop/                    # → ~/.config/htop
├── pulseeffects/            # → ~/.config/PulseEffects
├── vmpk/                    # → ~/.config/vmpk.sourceforge.net
├── ardour/                  # → ~/.config/ardour<N>/config, ui_config
├── solaar/                  # → ~/.config/solaar
├── nvim/                    # → ~/.config/nvim
│
│   # Dotfiles (symlinked to ~/)
├── bashrc, zshrc, shellrc   # Shell configs
├── vimrc, ideavimrc         # Editor configs
├── tmux.conf, tmux/         # Tmux config + plugins
├── gitconfig, gitignore     # Git config
├── touchegg.conf            # Trackpad gestures
├── kanata.kbd               # Keyboard remapping
└── tmp/                     # Gitignored temp files (backup zips, etc.)
```

### Design Principles

- **Drop a script, it runs.** The orchestrators (`ubuntu.sh`, `fedora.sh`, `common.sh`, `apps.sh`) glob `*.sh` in their folder. Add a new script and it's automatically picked up.
- **Symlink everything possible.** Config changes go straight to the repo.
- **dconf dump/load for GNOME.** GNOME settings live in a binary database, so we dump text files for version control and load them on restore.
- **Desktop file templates.** `.desktop` files use `%USER%` placeholders, resolved at install time.
- **Sensitive data stays out.** Backups go to `tmp/` (gitignored).
- **ARM gets a lean subset, not a smaller version of the same thing.** `setup/arm.sh` only symlinks dotfiles + nvim and installs CLI deps — no desktop apps, fonts, or GNOME steps ever run there.

## Shell Architecture

The shell setup is structured in layers:

```
~/.bashrc  →  dotfiles/bashrc  →  sources shellrc
~/.zshrc   →  dotfiles/zshrc   →  sources shellrc
```

**`shellrc`** — shared config for both bash and zsh:
- Sources `~/.bash_aliases` and `~/.bash_local`
- Sets keyboard repeat rate (`xset r rate 180 70` — fast, for vim)
- Configures Logitech K400/K380 mouse/keyboard mappings
- GNOME focus-follows-mouse (`sloppy` mode)
- PATH setup for nvim, Go, Python, Ruby (rbenv), Node (n), Cargo, Android SDK
- Auto-starts tmux and neofetch
- fzf integration for zsh history (`Ctrl+R`)
- Calibre dark mode via `CALIBRE_USE_DARK_PALETTE=1`

**`bash_aliases`** — main aliases file:
- Sources additional aliases from `aliases/` folder (modular)
- `~/.bash_local` for machine-specific or private config (gitignored)

### Notable Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `gst` | `git status` | Quick git status |
| `ga` | `git add` | Stage files |
| `gci` | `git commit` | Commit |
| `gc` | `git checkout` | Switch branches |
| `gd` / `gdc` | `git diff` / `git diff --cached` | View changes |
| `glg` | `git log --pretty=format:...` | Compact git log |
| `vim` | `nvim` | Auto-alias when neovim is installed |
| `c` | `clear` | Clear terminal |
| `cls` | `clear && ls` | Clear and list |
| `k` | `kubectl` | Kubernetes shortcut |
| `z` | `source ~/.zshrc` | Reload shell config |
| `xclip` | `xclip -selection c` | Copy to clipboard |
| `prettyjson` | `python -m json.tool` | Format JSON |
| `diskfree` | `df -h --total \| grep nvme` | Quick disk usage |
| `alert` | `notify-send + sound` | Notify when a long command finishes (`sleep 10; alert`) |
| `cache-clear-ubuntu` | `apt autoremove + autoclean + rm cache` | Free up space |
| `todo` | Opens Todoist in Chrome app mode | Quick task access |
| `dockerip` | `docker inspect ...` | Get container IP |

### Alias Modules (`aliases/`)

```
aliases/
├── docker.bash_aliases      # dockerip function
└── functions.bash_aliases   # alert, prettyjson, diskfree
```

## Backup & Restore

### Full Backup (before reinstall)

```bash
./backup/backup.sh
```

Creates a timestamped zip in `tmp/` with:
- SSH keys (`~/.ssh/`)
- AWS credentials (`~/.aws/`)
- Docker auth (`~/.docker/config.json`)
- mkcert root CA (`~/.local/share/mkcert/`)
- GNOME keyrings (`~/.local/share/keyrings/`)
- Git local config (`.gitconfig_local`)
- NPM config (`.npmrc`)
- GNOME settings (extensions, dconf, keybindings, guake)
- Sticky notes

### Restore (separate from setup)

Restore is **not** part of `setup.sh` — not all systems run GNOME or need the same credentials. After setup completes, restore manually:

```bash
# 1. Copy your backup zip to the machine (USB, cloud, scp, etc.)
cp /media/usb/backup-20260622-120000.zip ~/dotfiles/tmp/

# 2. See what backups are available
ls ~/dotfiles/tmp/backup-*.zip

# 3. Restore credentials + GNOME settings
./backup/restore.sh tmp/backup-20260622-120000.zip

# 4. Restore sticky notes separately (if needed)
ls ~/dotfiles/tmp/sticky-notes-*.zip
./backup/sticky-notes.sh restore tmp/sticky-notes-20260622.zip
```

The restore script handles SSH keys, AWS, Docker, mkcert, keyrings, gitconfig_local, npmrc, and GNOME settings — all with proper file permissions.

### Individual restore (if you only need one thing)

```bash
./backup/gnome.sh restore                              # GNOME only
./backup/sticky-notes.sh restore tmp/sticky-notes-*.zip  # Sticky notes only
```

## Pre-Reinstall Checklist

### Automated (`./backup/backup.sh`)

- [ ] GNOME settings (extensions, dconf, keybindings, guake)
- [ ] Sticky notes
- [ ] SSH keys
- [ ] AWS credentials
- [ ] Docker auth
- [ ] mkcert root CA
- [ ] GNOME keyrings
- [ ] Git local config
- [ ] NPM config

### Manual

- [ ] **Commit and push dotfiles** — `cd ~/dotfiles && git add -A && git commit && git push`
- [ ] **Browser** — Verify Chrome sync is up to date (bookmarks, extensions, passwords)
- [ ] **Calibre library** — Back up `~/Calibre Library/` if needed
- [ ] **Ardour projects** — Back up any active audio sessions
- [ ] **OBS Studio** — Back up scenes/profiles if customized
- [ ] **FortiClient VPN** — Note down VPN server addresses and credentials
- [ ] **IntelliJ settings** — Verify JetBrains settings sync is enabled
- [ ] **VS Code / Cursor** — Verify settings sync is enabled
- [ ] **Project repos** — Ensure all local repos are pushed
- [ ] **Downloads folder** — Check for anything important
- [ ] **Backup zip** — Copy `tmp/backup-*.zip` to USB or cloud storage

## Desktop Apps

Downloaded directly (not from package managers), installed to `~/apps/`:

```bash
./setup/apps/idea.sh         # IntelliJ IDEA → ~/apps/idea/
./setup/apps/postman.sh      # Postman → ~/apps/postman/
./setup/apps/vmpk.sh         # VMPK → ~/apps/vmpk/ (+ symlinked config & mappings)
./setup/apps/ardour.sh FILE  # Ardour → ~/apps/ardour/ (requires manual download)
```

## Utility Scripts

| Script | Description |
|--------|-------------|
| `disk-health.sh` | SMART health report for all drives (NVMe + SATA SSD/HDD). Shows temperature, life remaining, unsafe shutdowns, read/write totals. Auto-installs `smartmontools`. |
| `fix-nvme-sleep.sh` | Fixes NVMe sleep/wake hangs by adding `nvme_core.default_ps_max_latency_us=0` to GRUB. |
| `pactl_switch_sink.sh` | Cycle between audio output sinks (speakers, headphones, bluetooth). |
| `generate_cpf.sh` | Generate/validate Brazilian CPF numbers. |
| `generate_cnpj_bugado.sh` | Generate/validate Brazilian CNPJ numbers. |
| `share_folder_smb.sh` | Set up a Samba shared folder. |
| `thirds.sh` | Snap window to left/center/right third of screen. |
| `enable-hibernate.sh` | Add hibernate option to system (WIP). |

```bash
sudo ./scripts/disk-health.sh           # Check all drives
sudo ./scripts/fix-nvme-sleep.sh        # Fix NVMe sleep issues
./scripts/pactl_switch_sink.sh          # Switch audio output
```

# TODO

## Done

- [x] Git config
- [x] GNOME extensions and configs backup/restore
- [x] Remove git dependency from bootstrap
- [x] Sticky notes backup (sensitive content, gitignored)
- [x] PulseEffects config symlink
- [x] Touchegg config symlink + service setup
- [x] Desktop apps setup (IntelliJ, Postman, VMPK)
- [x] VMPK keymapping backup and symlink
- [x] Fedora equivalents for all Ubuntu setup scripts
- [x] Generic orchestrators (drop a script, it runs)
- [x] Debloat scripts (remove snap + flatpak)
- [x] Centralize symlinks in setup/symlinks.sh
- [x] Bootstrap one-liner (curl, no git needed)

## In Progress

- [ ] Save and restore vim sessions with tmux
- [ ] Enable system copy-paste with tmux

## Future Improvements

### Refactor to Ansible
- Replace bash scripts with Ansible playbooks for idempotency, better error handling, and cross-distro abstraction
- Use Ansible roles: `base`, `desktop`, `gnome`, `dev-tools`, `apps`
- Use `ansible-pull` for the bootstrap one-liner instead of curl | bash
- Leverage Ansible's `package` module to abstract apt/dnf differences
- Use Ansible `template` module instead of sed for `%USER%` replacement

### First-Class CLI Commands
- Make scripts in `scripts/` available as commands in `$PATH`
- Add `~/.local/bin` or `~/dotfiles/scripts` to PATH in shellrc
- Add proper `--help` and argument parsing to each script
- Scripts to promote: `pactl_switch_sink.sh`, `share_folder_smb.sh`, `generate_cpf.sh`

### Other
- [ ] Kanata: install binary to `/usr/local/bin` instead of `~/Programs`
- [ ] Move old `scripts/docker.sh` to `setup/common/docker.sh` (already done, clean up old)
- [ ] Add a `setup/desktop/cemu.sh` for the Wii emulator (desktop file exists, no setup script)
- [ ] Consolidate the gnome/ and backup/ todo files into this one
- [ ] Add health check script that verifies all symlinks and services are in place
- [ ] Add `--dry-run` flag to setup.sh to preview what would be changed
