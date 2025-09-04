# comfortable-swipe (buggy)
#sudo apt install -y g++ libinput-tools libinih-dev libxdo-dev
#cd ~/Programs
#git clone https://github.com/Hikari9/comfortable-swipe.git --depth 1
#cd comfortable-swipe
#bash install
#INPUT_GRP="$(ls -l /dev/input/event* | awk '{print $4}' | head --line=1)"
#sudo gpasswd -a "$USER" "$INPUT_GRP"
#newgrp "$INPUT_GRP"
#comfortable-swipe autostart on

#touchegg
sudo add-apt-repository ppa:touchegg/stable -y
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7EA12677D47B593CE22727D4C0FCE32AF6B96252
sudo apt update
sudo apt install -y touchegg
mkdir -p ~/.config/touchegg && ln -s ~/dotfiles/touchegg.conf ~/.config/touchegg/touchegg.conf

#@TODO - setup daemon


