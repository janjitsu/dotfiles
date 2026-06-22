# Dotfiles

Personal dotfiles and system setup automation for Ubuntu and Fedora workstations running GNOME.

One command on a fresh machine sets up everything — packages, configs, desktop apps, GNOME extensions, keybindings — exactly how it was before.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/janjitsu/dotfiles/master/bootstrap.sh | bash
```

No git required. The bootstrap downloads the repo as a tarball, runs setup, then initializes git for future updates.

## How It Works

### Bootstrap Flow

```
bootstrap.sh
  └── setup.sh
        ├── setup/ubuntu.sh  or  setup/fedora.sh   (distro packages)
        ├── setup/symlinks.sh                       (dotfile symlinks)
        ├── setup/common.sh                         (distro-agnostic tools)
        ├── setup/apps.sh                           (desktop apps)
        └── backup/gnome.sh restore                 (GNOME settings)
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
│   ├── common.sh            # Runs all setup/common/*.sh
│   ├── apps.sh              # Runs all setup/apps/*.sh
│   ├── symlinks.sh          # All symlink operations
│   ├── ubuntu/              # apt-based installs (one script per tool)
│   ├── fedora/              # dnf-based installs (mirrors ubuntu/)
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

### Restore (after reinstall)

```bash
./backup/restore.sh tmp/backup-YYYYMMDD-HHMMSS.zip
```

Restores all credentials with proper permissions, plus GNOME settings.

### Individual backup/restore

```bash
./backup/gnome.sh backup          # GNOME only
./backup/gnome.sh restore
./backup/sticky-notes.sh backup   # Sticky notes only
./backup/sticky-notes.sh restore tmp/sticky-notes-*.zip
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
