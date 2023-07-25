My dotfiles
==========

Simplest possible way I've found to manage my dotfiles

Included:

* wget
* curl
* neovim
* tmux
* bash
* zsh
* gitconfig

Requirements:

* git


***

### Setup

* clone it to your home folder

```
$ git clone git@github.com:janfrs/dotfiles.git ~/dotfiles
```

* run setup

```
$ ./setup.sh
```

This will symlink all files/folders to your home dir. Any existent file will be moved to ~/dotfiles_old directory

### Vim

Plugins are managed with [Vundle](https://github.com/VundleVim/Vundle.vim)

### Tmux

Plugins are managed with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

### Bash
Any machine-specific or private config can be placed on `.bash_local` file

***

### Todo

- [X] Git config
- [ ] Enable vim folding
- [ ] Improve setup automation to not ask for sudo
- [ ] Save and restore vim sessions with tmux
- [ ] Enable system copy-paste with tmux

***

### Other Scripts

Still testing these to include them in the main setup script

* Docker installer

```
$ ./scripts/docker.sh
```

* Import gsettings shortcuts
```
$ ./scripts/keybindings.pl -i ~/dotfiles/gsettings.csv
```



setup file was inspired by: [this](http://blog.smalleycreative.com/tutorials/using-git-and-github-to-manage-your-dotfiles/)
