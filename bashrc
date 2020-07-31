[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable to show git branch when in a git repository
# source: https://github.com/jimeh/git-aware-prompt/blob/master/prompt.sh
# added highlighting of repo part in path
function find_git_branch {
    git_subpath='/'
    local dir=${PWD} head
    until [ "$dir" = "" ]; do
        if [ -f "$dir/.git/HEAD" ]; then
            head=$(< "$dir/.git/HEAD")
            if [[ $head == ref:\ refs/heads/* ]]; then
                git_branch=" (${head#*/*/})"
            elif [[ $head != '' ]]; then
                git_describe=$(git describe --always)
                git_branch=" (detached: $git_describe)"
            else
                git_branch=' (unknown)'
	        fi
	        prompt_dir="${dir/$HOME/~}"
            return
        fi
        git_subpath="/${dir##*/}$git_subpath"
        dir="${dir%/*}"
    done
    git_branch=''
    prompt_dir="${PWD/$HOME/~}"
    git_subpath=''
}
function find_git_dirty {
    st=$(git status -s 2>/dev/null | tail -n 1)
    if [[ $st == "" ]]; then
        git_dirty=''
    else
        git_dirty='*'
    fi
}
PROMPT_COMMAND="find_git_branch; find_git_dirty; $PROMPT_COMMAND"
GREEN="\\[\\033[01;32m\\]"
WHITE="\\[\\033[00m\\]"
BLUE="\\[\\033[01;34m\\]"
CYAN="\\[\\e[1;36m\\]"
RED="\\[\\e[0;31m\\]"
YELLOW="\\[\\e[1;33m\\]"
PS1="$GREEN\u@\h$WHITE: $BLUE\$prompt_dir$CYAN\$git_subpath$RED\$git_branch$YELLOW\$git_dirty\n$WHITE\$(date +"%H:%M:%S") $BLUE\$$WHITE "

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
function alert {
    notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" \
    "$(history|tail -n1|sed -e 's/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//')"
    for i in {1..3}; do
        pacmd play-file /usr/share/sounds/gnome/default/alerts/glass.ogg alsa_output.pci-0000_00_1f.3.analog-stereo; sleep 0.2
    done
}

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# local per-machine configurations
if [ -e ~/.bash_local ]; then
    . ~/.bash_local
fi

#stop ctrl+s ctrl+q behavior
stty -ixon

# set keyboard speed
xset r rate 180 70

# gnome specific keyboard speed and mouse focus
if [ "$(type -t gsettings)" = file ]
then
    gsettings set org.gnome.desktop.peripherals.keyboard delay 180
    gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 10
    gsettings set org.gnome.desktop.wm.preferences focus-mode sloppy
fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin:$HOME/.local/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).
