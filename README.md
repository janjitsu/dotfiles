My dotfiles
==========

### Quick Setup (fresh machine, no git required)

```bash
curl -fsSL https://raw.githubusercontent.com/janjitsu/dotfiles/master/bootstrap.sh | bash
```

### Manual Setup

```bash
git clone git@github.com:janjitsu/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

This will symlink all files/folders to your home dir. Any existent file will be moved to ~/dotfiles_old directory.

***

### What's included

* git, wget, curl
* neovim, vim
* tmux
* bash, zsh
* htop
* gitconfig
* PulseEffects
* Touchegg (trackpad gestures)

### Backup & Restore

```bash
# GNOME settings, extensions, keybindings
./backup/gnome.sh backup
./backup/gnome.sh restore

# Sticky notes (sensitive — saved to gitignored tmp/)
./backup/sticky-notes.sh backup
./backup/sticky-notes.sh restore tmp/sticky-notes-YYYYMMDD.zip
```

### Desktop Apps

```bash
# Install all desktop apps (IntelliJ, Postman, VMPK)
./setup/apps.sh

# Or individually
./setup/desktop/idea.sh
./setup/desktop/postman.sh
./setup/desktop/vmpk.sh
```

### Vim

Plugins are managed with [vim-plug](https://github.com/junegunn/vim-plug)

### Tmux

Plugins are managed with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

### Bash
Any machine-specific or private config can be placed on `.bash_local` file
