#!/bin/bash
############################
# setup.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

##### INSTALL PROGRAMS #####
#

#TODO install nvim and copy configs to ~/.config/nvim/init.vim

sudo apt update
sudo apt install -yq wget curl git python3-neovim tmux zsh

# zsh
chsh -s /usr/bin/zsh $USER
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

# to use powerline theme on gnome-terminal
# git clone https://github.com/powerline/fonts.git --depth=1
# ./fonts/install.sh
# rm -rf fonts
# dconf load /org/gnome/terminal/legacy/profiles:/ < gnome-terminal-profiles.dconf

# docker
#apt install -yq ca-certificates curl gnupg lsb-release
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
#apt update
#apt install -yq docker-ce docker-ce-cli containerd.io
#usermod -aG docker $USER
#newgrp docker
#systemctl enable docker.service
#systemctl enable containerd.service

# golang
wget -c https://go.dev/dl/go1.17.4.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local/
sudo chown janjitsu.janjitsu /usr/local/go/bin

##### INSTALL PROGRAMS #####

########## Variables

dir=~/dotfiles                    	    # dotfiles directory
olddir=~/dotfiles_old                   # old dotfiles backup directory

# list of files/folders to symlink in homedir
files="bashrc shellrc vimrc ideavimrc vim bash_aliases tmux.conf tmux gitconfig gitignore ackrc zshrc"

##########

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks
for file in $files; do
    echo "Moving existing $file from ~ to $olddir"
    mv ~/.$file ~/dotfiles_old/
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/.$file
done

source ~/.bashrc
#nvim init
mkdir -p ~/.config/nvim
ln -s ~/dotfiles/init.vim ~/.config/nvim/init.vim

# install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +qa

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
bash ~/.tmux/plugins/tpm/bin/install_plugins

