My dotfiles
==========

Simplest possible way I've found to manage my dotfiles

Included:

* git
* wget
* curl
* neovim
* tmux
* bash
* zsh
* gitconfig

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

setup file was inspired by: [this](http://blog.smalleycreative.com/tutorials/using-git-and-github-to-manage-your-dotfiles/)
