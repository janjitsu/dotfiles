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
│   ├── gnome.sh             # GNOME backup/restore (extensions, dconf, keybindings)
│   ├── sticky-notes.sh      # Sticky notes backup/restore (sensitive, gitignored zip)
│   └── gnome_keybindings.pl # Keybinding import/export via gsettings
│
├── gnome/                   # GNOME backup artifacts (committed)
│   ├── extensions-*.list    # Extension lists for reinstall
│   ├── dconf/               # dconf dumps (shell, desktop, extensions, terminal, guake)
│   └── gsettings.csv        # Custom keybindings
│
├── scripts/                 # Utility scripts (disk-health, fix-nvme-sleep, etc.)
│
│   # Config directories (symlinked to ~/.config/)
├── htop/                    # → ~/.config/htop
├── pulseeffects/            # → ~/.config/PulseEffects
├── vmpk/                    # → ~/.config/vmpk.sourceforge.net
├── ardour/                  # → ~/.config/ardour<N>/config, ui_config
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
- **Sensitive data stays out.** Sticky notes backup goes to `tmp/` (gitignored).

## Backup & Restore

```bash
# GNOME (extensions + settings + keybindings)
./backup/gnome.sh backup
./backup/gnome.sh restore

# Sticky notes (creates zip in tmp/)
./backup/sticky-notes.sh backup
./backup/sticky-notes.sh restore tmp/sticky-notes-YYYYMMDD.zip
```

## Desktop Apps

Downloaded directly (not from package managers), installed to `~/apps/`:

```bash
./setup/apps/idea.sh         # IntelliJ IDEA → ~/apps/idea/
./setup/apps/postman.sh      # Postman → ~/apps/postman/
./setup/apps/vmpk.sh         # VMPK → ~/apps/vmpk/ (+ symlinked config & mappings)
./setup/apps/ardour.sh FILE  # Ardour → ~/apps/ardour/ (requires manual download)
```

## Utility Scripts

```bash
sudo ./scripts/disk-health.sh          # SMART health check for all drives
sudo ./scripts/fix-nvme-sleep.sh       # Fix NVMe sleep/wake issues via GRUB
```

## Shell

Machine-specific or private config goes in `.bash_local` (gitignored).
