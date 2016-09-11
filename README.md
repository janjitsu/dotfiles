My dotfiles
==========

Simplest possible way I've found to manage my dotfiles

Included:

* vim
* tmux
* bash

***

###Setup

* clone it

```$ git clone git@github.com:janfrs/dotfiles.git```

* run setup

```$ ./setup.sh```

This will symlink all files/folders to your home dir. Any existent file will be moved to ~/dotfiles_old directory

####Vim

Plugins are managed with [Vundle](https://github.com/VundleVim/Vundle.vim)

Install them by running

```$ vim +BundleInstall +qa``` 

####Tmux

Plugins are managed with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

install them by running (on tmux)

```Ctrl+a + I```

####Bash
Any machine-specific or private config can be described on `.bash_local` file




setup file was inspired by: [this](http://blog.smalleycreative.com/tutorials/using-git-and-github-to-manage-your-dotfiles/)


