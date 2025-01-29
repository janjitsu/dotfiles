#!/bin/bash
############################
# setup.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

##### INSTALL PROGRAMS #####
#

#TODO install nvim and copy configs to ~/.config/nvim/init.vim
if command -v apt-get >/dev/null; then
    sudo apt update
    sudo apt install -y wget curl python3-neovim tmux zsh htop ack-grep silversearcher-ag fzf
elif command -v yum >/dev/null; then
    sudo yum update
    sudo yum install -y wget curl python3-neovim tmux zsh htop ack silversearcher-ag
fi

# zsh
chsh -s /usr/bin/zsh $USER
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

# to use powerline theme on gnome-terminal
git clone https://github.com/powerline/fonts.git --depth=1
./fonts/install.sh
rm -rf fonts
dconf load /org/gnome/terminal/legacy/profiles:/ < gnome-terminal-profiles.dconf

## Node
curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | bash -s lts
npm install -g n

##### INSTALL DOTFILES #####

########## Variables

dir=~/dotfiles                    	    # dotfiles directory
olddir=~/dotfiles_old                   # old dotfiles backup directory

# list of files/folders to symlink in homedir
files="bashrc shellrc zshrc bash_local bash_aliases vimrc ackrc ideavimrc vim tmux.conf tmux gitconfig gitignore"

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
# Neovim init
mkdir -p ~/.config/nvim
ln -s ~/dotfiles/nvim/init.vim ~/.config/nvim/init.vim
ln -s ~/dotfiles/nvim/coc-settings.json ~/.config/nvim/coc-settings.json

# install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +qa

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
bash ~/.tmux/plugins/tpm/bin/install_plugins

# htop
mv ~/.config/htop/htoprc ~/dotfiles_old/
if [! -d ~/.config/htop ]; then mkdir -p ~/.config/htop/; fi
ln -s $dir/htoprc ~/.config/htop/htoprc
